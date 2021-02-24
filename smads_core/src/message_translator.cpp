#include <actionlib_msgs/GoalStatus.h>
#include <geometry_msgs/Pose2D.h>
#include <geometry_msgs/Quaternion.h>
#include <nav_msgs/Path.h>
#include <regex>
#include <ros/ros.h>
#include <ros/console.h>
#include "ros/package.h"
#include "ros_type_introspection/ros_introspection.hpp"
#include "smads_core/gps_translator.h"
#include <tf/tf.h>
#include <topic_tools/shape_shifter.h>
#include <mutex>

using namespace RosIntrospection;
using topic_tools::ShapeShifter;

static std::vector<uint8_t> localization_buffer, goal_status_buffer, planned_path_buffer;
static FlatMessage localization_container, goal_status_container, planned_path_container;
static RenamedValues rv_localization, rv_goal_status, rv_planned_path;

const std::string map_to_gps_output_topic = "/smads/localization/out/gps";
const std::string goal_status_output_topic = "/smads/navigation/out/status";
const std::string planned_path_output_topic = "/smads/navigation/out/planned_path";

ros::Publisher gps_localization_pub_;
ros::Publisher navigation_status_pub_;
ros::Publisher planned_path_pub_;
geometry_msgs::PointStamped gps_localization_msg_;
std::string navigation_topic_out;
GPSTranslator* gps_;
std::string map;
std::string maps_dir;
std::mutex gps_mutex;

// Generic Localization-based message translation

geometry_msgs::Pose2D amrl_localization2dmsg(RenamedValues rv, std::string topic_name) {
   geometry_msgs::Pose2D res;
   
   for (auto it: rv)
   {
        std::string& key = it.first;
        const Variant& value   = it.second;
	const double variant_val = value.convert<double>();

	// erase topic name from key, +1 for the additional /
	std::string::size_type i = key.find(topic_name);
	if (i != std::string::npos)
   	    key.erase(i, topic_name.length()+1);

	// template is as follows
	// case(unique field name) : standard_msg.equivilent_field_name = value conversion
	// of correct type
	if (strcmp(key.c_str(), "pose/x") == 0) { res.x = variant_val; } 
	else if (strcmp(key.c_str(), "pose/y") == 0) { res.y = variant_val; } 
	else if (strcmp(key.c_str(), "pose/theta") == 0) { res.theta = variant_val; } 
    }
  return res;
}

geometry_msgs::Pose2D geometry_posestamped(RenamedValues rv, std::string topic_name) {
   geometry_msgs::Pose2D res;
   geometry_msgs::Quaternion quat;
   for (auto it: rv)
   {
        std::string& key = it.first;
        const Variant& value   = it.second;
	const double variant_val = value.convert<double>();
	
	// erase topic name from key, +1 for the additional /
	std::string::size_type i = key.find(topic_name);
	if (i != std::string::npos)
   	    key.erase(i, topic_name.length()+1);

	// template is as follows
	// case(unique field name) : standard_msg.equivilent_field_name = value conversion
	// of correct type
	if (strcmp(key.c_str(), "pose/position/x") == 0) { res.x = variant_val; } 
	else if (strcmp(key.c_str(), "pose/position/y") == 0) { res.y = variant_val; } 
	else if (strcmp(key.c_str(), "pose/orientation/x") == 0) { quat.x = variant_val; }
	else if (strcmp(key.c_str(), "pose/orientation/y") == 0) { quat.y = variant_val; }
	else if (strcmp(key.c_str(), "pose/orientation/z") == 0) { quat.z = variant_val; }
	else if (strcmp(key.c_str(), "pose/orientation/w") == 0) { quat.w = variant_val; }


    }
    //convert quaternion to euler
    tf::Quaternion q(quat.x, quat.y, quat.z, quat.w);
    double roll, pitch, yaw;
    tf::Matrix3x3(q).getRPY(roll, pitch, yaw);
    res.theta = yaw;
    return res;
}

// Planned Path message conversion
nav_msgs::Path nav_path(RenamedValues rv, std::string topic_name) {
   nav_msgs::Path res;
   const std::regex base_regex_x("(poses.+)\\/pose/position/x");
   const std::regex base_regex_y("(poses.+)\\/pose/position/y");
   
   geometry_msgs::PoseStamped ps;
   for (auto it: rv)
   {
        std::string& key = it.first;
        const Variant& value   = it.second;
	const double variant_val = value.convert<double>();
	
	// erase topic name from key, +1 for the additional /
	std::string::size_type i = key.find(topic_name);
	if (i != std::string::npos)
   	    key.erase(i, topic_name.length()+1);
	std::smatch base_match;
	if (std::regex_match(key, base_match, base_regex_x)) { ps.pose.position.x = variant_val; } 
	else if (std::regex_match(key, base_match, base_regex_y)) { ps.pose.position.y = variant_val; 
		res.poses.push_back(ps);
	} 

    }
   return res;
}

void convert_path_to_GPS(nav_msgs::Path* path){
    for(int i = 0; i < path->poses.size(); i++){
        gps_mutex.lock();
	const Vector2d p = gps_->MetricToGps(path->poses[i].pose.position.x, path->poses[i].pose.position.y);
        gps_mutex.unlock();
        path->poses[i].pose.position.x = p.x();
        path->poses[i].pose.position.y = p.y();
    }
}

void localizationCallback(const ShapeShifter::ConstPtr& msg,
                   const std::string &topic_name,
                   RosIntrospection::Parser& parser)
{

    const std::string&  datatype   =  msg->getDataType();
    const std::string&  definition =  msg->getMessageDefinition();

    std::string msg_pkg = datatype.substr(0, datatype.find("/"));
    std::string msg_name = datatype.substr(datatype.find("/")+1, datatype.length());

    parser.registerMessageDefinition( topic_name,
                                      RosIntrospection::ROSType(datatype),
                                      definition );

    // copy raw memory into the buffer
    localization_buffer.resize( msg->size() );
    ros::serialization::OStream stream(localization_buffer.data(), localization_buffer.size());
    msg->write(stream);

    parser.deserializeIntoFlatContainer( topic_name, Span<uint8_t>(localization_buffer), &localization_container, 100);
    parser.applyNameTransform( topic_name, localization_container, &rv_localization );

    geometry_msgs::Pose2D out_msg;
    if (strcmp(msg_pkg.c_str(), "amrl_msgs") == 0) {
        if (strcmp(msg_name.c_str(), "Localization2DMsg") == 0) {
             out_msg = amrl_localization2dmsg(rv_localization, topic_name);
             gps_mutex.lock();
  	     const Vector2d p = gps_->MetricToGps(out_msg.x, out_msg.y);
             gps_mutex.unlock();
	     gps_localization_msg_.header.stamp = ros::Time::now();
             gps_localization_msg_.point.x = p.x();
             gps_localization_msg_.point.y = p.y();
	     // NOTE that this may be a bug. TODO check if theta needs to be transformed via gps library as well
             gps_localization_msg_.point.z = out_msg.theta;
             gps_localization_pub_.publish(gps_localization_msg_);
        }
    }
    else {
	ROS_WARN("Message type %s from package %s is not supported in SMADS message translator. Could not translate message.", msg_name.c_str(), msg_pkg.c_str());
	return;
    }

}

void goalStatusCallback(const ShapeShifter::ConstPtr& msg,
                   const std::string &topic_name,
                   RosIntrospection::Parser& parser)
{

    const std::string&  datatype   =  msg->getDataType();
    const std::string&  definition =  msg->getMessageDefinition();

    std::string msg_pkg = datatype.substr(0, datatype.find("/"));
    std::string msg_name = datatype.substr(datatype.find("/")+1, datatype.length());

    parser.registerMessageDefinition( topic_name,
                                      RosIntrospection::ROSType(datatype),
                                      definition );

    // copy raw memory into the buffer
    goal_status_buffer.resize( msg->size() );
    ros::serialization::OStream stream(goal_status_buffer.data(), goal_status_buffer.size());
    msg->write(stream);

    parser.deserializeIntoFlatContainer( topic_name, Span<uint8_t>(goal_status_buffer), &goal_status_container, 100);
    parser.applyNameTransform( topic_name, goal_status_container, &rv_goal_status );

    actionlib_msgs::GoalStatus out_msg;
    if (strcmp(msg_pkg.c_str(), "actionlib_msgs") == 0) {
        if (strcmp(msg_name.c_str(), "GoalStatus") == 0) {
             // message is already the standard type, send it forward
             navigation_status_pub_.publish(msg);
        }
    }
    else {
	ROS_WARN("Message type %s from package %s is not supported in SMADS message translator. Could not translate message.", msg_name.c_str(), msg_pkg.c_str());
	return;
    }

}

void plannedPathCallback(const ShapeShifter::ConstPtr& msg,
                   const std::string &topic_name,
                   RosIntrospection::Parser& parser)
{
    const std::string&  datatype   =  msg->getDataType();
    const std::string&  definition =  msg->getMessageDefinition();

    std::string msg_pkg = datatype.substr(0, datatype.find("/"));
    std::string msg_name = datatype.substr(datatype.find("/")+1, datatype.length());

    parser.registerMessageDefinition( topic_name,
                                      RosIntrospection::ROSType(datatype),
                                      definition );

    // copy raw memory into the buffer
    planned_path_buffer.resize( msg->size() );
    ros::serialization::OStream stream(planned_path_buffer.data(), planned_path_buffer.size());
    msg->write(stream);

    parser.deserializeIntoFlatContainer( topic_name, Span<uint8_t>(planned_path_buffer), &planned_path_container, 100);
    parser.applyNameTransform( topic_name, planned_path_container, &rv_planned_path );

    nav_msgs::Path out_msg;
    if (strcmp(msg_pkg.c_str(), "nav_msgs") == 0) {
        if (strcmp(msg_name.c_str(), "Path") == 0) {
             out_msg = nav_path(rv_planned_path, topic_name);
             convert_path_to_GPS(&out_msg);
             planned_path_pub_.publish(out_msg);
        }
    }
    else {
	ROS_WARN("Message type %s from package %s is not supported in SMADS message translator. Could not translate message.", msg_name.c_str(), msg_pkg.c_str());
	return;
    }

}

int main(int argc, char** argv)
{
    Parser localization_parser, goal_status_parser, planned_path_parser;
    gps_ = new GPSTranslator();
    ros::init(argc, argv, "smads_ros_topic_translator");
    ros::NodeHandle nh;
    // Get input topics, etc
    std::string localization_topic_in;
    std::string goal_status_topic_in;
    std::string planned_path_topic_in;
    nh.param<std::string>("/smads/in/localization/topic", localization_topic_in, "/localization");
    nh.param<std::string>("/smads/in/navigation/status/topic", goal_status_topic_in, "/navigation_goal_status");
    nh.param<std::string>("/smads/in/navigation/planned_path/topic", planned_path_topic_in, "/trajectory");
    nh.param<std::string>("/smads/in/localization/map_name", map, "UT_Campus");
    nh.param<std::string>("/smads/in/localization/maps_dir", maps_dir, ros::package::getPath("amrl_maps"));
    gps_->Load(map, maps_dir);

    gps_localization_pub_ = nh.advertise<geometry_msgs::PointStamped>(map_to_gps_output_topic, 1);
    navigation_status_pub_ = nh.advertise<actionlib_msgs::GoalStatus>(goal_status_output_topic, 1);
    planned_path_pub_ = nh.advertise<nav_msgs::Path>(planned_path_output_topic, 1);

    // Localization cb
    boost::function<void(const topic_tools::ShapeShifter::ConstPtr&) > loc_callback;
    loc_callback = [&localization_parser, localization_topic_in](const topic_tools::ShapeShifter::ConstPtr& msg) -> void
    {
        localizationCallback(msg, localization_topic_in, localization_parser) ;
    };
    // Navigation Goal Status cb
    boost::function<void(const topic_tools::ShapeShifter::ConstPtr&) > goal_status_callback;
    goal_status_callback = [&goal_status_parser, goal_status_topic_in](const topic_tools::ShapeShifter::ConstPtr& msg) -> void
    {
        goalStatusCallback(msg, goal_status_topic_in, goal_status_parser) ;
    };
    // Planned Path cb
    boost::function<void(const topic_tools::ShapeShifter::ConstPtr&) > planned_path_callback;
    planned_path_callback = [&planned_path_parser, planned_path_topic_in](const topic_tools::ShapeShifter::ConstPtr& msg) -> void
    {
        plannedPathCallback(msg, planned_path_topic_in, planned_path_parser) ;
    };


    ros::Subscriber localization_input_subscrber = nh.subscribe(localization_topic_in, 10, loc_callback);
    ros::Subscriber goal_status_input_subscrber = nh.subscribe(goal_status_topic_in, 10, goal_status_callback);
    ros::Subscriber planned_path_input_subscrber = nh.subscribe(planned_path_topic_in, 10, planned_path_callback);
    
    ros::spin();
    return 0;
}

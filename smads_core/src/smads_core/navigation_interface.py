#!/usr/bin/env python
from importlib import import_module
from geometry_msgs.msg import Quaternion, PointStamped, Pose2D
from rospy_message_converter import message_converter
from sensor_msgs.msg import NavSatFix
from std_msgs.msg import Header
import rospy
import roslib

"""
This implements a generic publication interface for the SMADS robot-side architecture.
What is meant by generic? Generic in the sense that the required message types for the 
deployed robot are not known apriori and are not explicitly required to be imported 
by this library at run-time.

These messages are assumed to exist on the system that this archiecture is deployed on 
(e.g., the robot), but it alleviates the burden on clients to install and import messages
for every robot system that is supported by this archiecture.

For a generic subscription model, please see `message_translator.cpp` in the same 
repository.

Author Max Svetlik 2020
"""


"""
AnyListener can be used to glean the message type, definition and class of a topic 
that is already published.
"""
class AnyListener(object):
    def __init__(self, topic='move_base_simple/goal'):
        self.pkg_name = None
        self.msg_name = None
        self.msg_class = None

        topics = [i[0].strip('/') for i in rospy.get_published_topics()]
        if topic not in topics:
            rospy.logerr("Input topic {} not present. Cannot glean message information.", input_topic)
            return 0

        self._binary_sub = rospy.Subscriber(topic, rospy.AnyMsg, self.topic_callback)


    def topic_callback(self, data):
        connection_header =  data._connection_header['type'].split('/')
        ros_pkg = connection_header[0]
        msg_type = connection_header[1]
        #print('Message type detected as ' + msg_type)
        msg_class = getattr(import_module(ros_pkg+'.msg'), msg_type)
        self._binary_sub.unregister()       
        self.pkg_name = ros_pkg
        self.msg_name = msg_type
        self.msg_class = msg_class

    def get_pkg_name(self):
        return self.pkg_name
 
    def get_msg_name(self):
        return self.msg_name

    def get_msg_class(self):
        return self.msg_class

    def get_qualified_name(self):
        return self.pkg_name + '/' + self.msg_name


"""
Creates a publisher based on string descriptions of the input `msg_type` and `ros_pkg`
Example of expected format:
    output_topic='/output'
    msg_type='Pose2Df'
    ros_pkg='amrl_msgs'
"""
class GenericPublisher:
    def __init__(self, output_topic, msg_type, ros_pkg):
        self.output_topic = output_topic
        self.msg_type = msg_type
        self.ros_pkg = ros_pkg
        self.qualified_name = ros_pkg+'/'+msg_type
        # ensure package can be found if its not catkinized
        roslib.load_manifest(self.ros_pkg)
        self.msg_class = getattr(import_module(self.ros_pkg+'.msg'), self.msg_type)
        self.pub = rospy.Publisher(self.output_topic, self.msg_class, queue_size=10)

    # Take in navigation specific data, assemble into a supported message type
    # types: x,y,z,theta,z 	: floats
    #        quaternion		: geometry_msgs/Quaternion
    #	     header		: std_msgs/Header
    def publish(self, x , y, theta=None, z=None, quaternion=None, header=None):
        if self.qualified_name == "amrl_msgs/Pose2Df":
                assert theta is not None
                dictionary = { 'x': x, 'y':y, 'theta':theta }
                message = message_converter.convert_dictionary_to_ros_message(self.qualified_name, dictionary)
                rospy.logdebug(message)
                #TODO remove this potential endless loop
                while self.pub.get_num_connections() < 1 :
                    rospy.sleep(0.05)
                self.pub.publish(message)
        if self.qualified_name == "geometry_msgs/PoseStamped":
                assert theta is not None
                header = {}
                pose = { 'x': x, 'y':y, 'z':0  }
                position= { 'position' : pose}
                orientation = {}
                dictionary = { 'pose':position }
                message = message_converter.convert_dictionary_to_ros_message(self.qualified_name, dictionary)
                rospy.logdebug(message)
                #TODO remove this potential endless loop
                while self.pub.get_num_connections() < 1 :
                    rospy.sleep(0.05)
                self.pub.publish(message)


class SMADSNavigationInterface:
    NAVIGATION_IN_TOPIC = "/smads/navigation/in/cmd"
    

    def __init__(self):
        self.navigation_in_sub = rospy.Subscriber(self.NAVIGATION_IN_TOPIC, Pose2D, self.gps_waypoint_cb)
        self.gps_translator_sub = rospy.Subscriber("/smads/gps_to_map/result", PointStamped, self.gps_translator_cb)
        self.gps_translator_pub = rospy.Publisher("/smads/gps_to_map/input", NavSatFix, queue_size=1)
	
        # All these parameters should be set explicitly
        nav_out_topic = rospy.get_param("/smads/out/navigation/topic", 'move_base_simple/goal')
        nav_out_msg_type = rospy.get_param("smads/out/navigation/msg_type", 'Pose2Df')
        nav_out_msg_pkg = rospy.get_param("smads/out/navigation/msg_pkg", 'amrl_msgs')
        self.nav_pub = GenericPublisher(nav_out_topic, nav_out_msg_type, nav_out_msg_pkg)    

    def gps_waypoint_cb(self, data):
        nav = NavSatFix()
        nav.latitude = data.x
        nav.longitude = data.y
        self.gps_translator_pub.publish(nav)

    # Note this is kind of dangerous, since it assumes that all gps translations it receives
    # correspond to data sent from this interface. 
    # TODO make gps translator a library, not ROS interface
    def gps_translator_cb(self, data):
        pose = Pose2D()
        pose.x = data.point.x
        pose.y = data.point.y

        # send goal
        self.nav_pub.publish(data.point.x, data.point.y, theta=0, z=0)

if __name__ == '__main__':
    rospy.init_node('smads_publication_interface')

    nav_int = SMADSNavigationInterface()
    rospy.spin()
   

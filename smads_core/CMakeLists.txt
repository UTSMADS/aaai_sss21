cmake_minimum_required(VERSION 2.8.3)
project(smads_core)

add_compile_options(-std=c++11)

find_package(Boost REQUIRED COMPONENTS regex)
find_package(Eigen3 REQUIRED)


find_package(catkin REQUIRED COMPONENTS 
    rospy
    roscpp
    std_msgs
    actionlib_msgs
    ros_type_introspection
    topic_tools
    nav_msgs
    sensor_msgs
    geometry_msgs
    message_generation
    genmsg
    tf
    roslib
    )

catkin_python_setup()

###################################
## catkin specific configuration ##
###################################
catkin_package(
    INCLUDE_DIRS include
    LIBRARIES ${PROJECT_NAME}

    CATKIN_DEPENDS
    actionlib_msgs
    nav_msgs
    ros_type_introspection
    topic_tools
    geometry_msgs
    message_runtime

    DEPENDS
    )

###########
## Build ##
###########

include_directories(
    include
    ${catkin_INCLUDE_DIRS}
    ${Eigen_INCLUDE_DIRS}
)

add_library(gps_translator src/gps_translator.cc)

add_executable(message_translator src/message_translator.cpp)
target_link_libraries(message_translator gps_translator ${catkin_LIBRARIES})

add_executable(gps_translator_node src/gps_translator_node.cpp)
target_link_libraries(gps_translator_node gps_translator ${catkin_LIBRARIES})


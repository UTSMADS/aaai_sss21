# smads_core
Core modules for the SMADS robot-side delivery pipeline

## Installation and Running
This library strives to minimize external dependencies, while providing a basic interface for other platforms to implement over. 

Therefore, it is recommended that any implementation for a given platform be done outside of this library and repository.

In the root of your catkin workspace, fetch the package dependencies:

    $ rosdep install --from-paths src --ignore-src --rosdistro=melodic

now, simply invoke catkin tools:

    $ catkin build smads_core


## ROS usage - For Application Servers

The SMADS architecture is flexible on the data it receives and sends on a particular robot platform. However, it offers standard input and output topics for communication to standard apps. Here, we go into these details.

### Data Output
This is data output from the platform and homogenized into the standard message types below.

#### Localization / estimated current robot position in Lat/Long
Topic: 		/smads/localization/out/gps

Message Type: 	geometry_msgs/PointStamped

#### Goal Status
Topic: 		/smads/navigation/out/status

Message Type:	actionlib_msgs/GoalStatus

#### Goal's Planned Path
Topic: 		/smads/navigation/out/planned_path

Message Type:	nav_msgs/Path

### Data Input
This is data or commands you want to send to the platform. The architecture takes the data from these standard message types below and decomposes them into messages that are acceptable to the platform.

#### Send navigation goal to platform 
Topic:		/smads/navigation/in/cmd

Message Type:	geometry_msgs/Pose2D

## ROS usage - For Robot Platform Deployment with existing ROS systems

As alluded to above, the architecture is platform independent and can be reconfigured to work with new platforms easily. How to configure the architecture is nominally handled through rosparameters, which are detailed here.

### Localization

#### /smads/in/localization/topic
This parameter should be a string that specifies the topic that your platform publishes localization location estimates. The message type is handled by the archietecture.

#### /smads/in/localization/map_name
This parameter should be a string that specifies the name of the map that the archiecture should use to convert location estimates from the map frame to GPS coordinates. E.g. `UT_Campus`

#### /smads/in/localization/maps_dir
This parameter should be a string that specifies the directory that the map specified above lives. This should generally be the local path of a package that has the map files.

### Navigation 

#### /smads/out/navigation/topic
This parameter should be a string that specifies the topic that your robot platform listens for and responds to navigation goals. E.g. `/move_base_simple/goal`

#### /smads/out/navigation/msg_type
This parameter should be a string that specifies the name of the message that your robot platform listens for on the topic detailed above. E.g. `PoseStamped`

#### /smads/out/navigation/msg_pkg
This parameter should be a string that specifies the name of the package the message type detailed above belongs to. E.g. `geometry_msgs`

#### /smads/in/navigation/status/topic
This parameter should be a string that specifies the topic that navigation goal status is published on. At a minimum, this topic should convey that the robot is in one of these states: (pending, active / executing goal, goal success, goal failure)

#### /smads/in/navigation/planned_path/topic
This parameter should be a string that specifies the topic on which the navigation publishes its global plan to its target goal.

## API Implementation - For Platform Development through APIs

This library implements an abstract class in `robot_client.py` that allows a developer to implement standardized methods that the architecture will call.

For some of these methods, the data returned is communicated over ROS for core functions such as Navigation or Localization that expect ROS communication.

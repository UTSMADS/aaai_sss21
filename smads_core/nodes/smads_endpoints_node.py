#!/usr/bin/env python3

import rospy
import threading

from enum import Enum

from smads_core.client import JackalClient
from smads_core.client import SpotClient
from smads_core.client import RobotClient

from smads_core.interface import RobotSensorInterface
from smads_core.interface import RobotNavigationInterface

class RobotType:
    SPOT    = 1
    JACKAL  = 2

    platform_map = {
        SPOT : SpotClient(),
        JACKAL : JackalClient(),
    }

class SMADSROS:
    def __init__(self, client, sensor_poll_rate, robot_prefix="smads_platform"):
        self.client = client
        self.robot_prefix = robot_prefix
        self.client_mutex = threading.Lock()
        self.sensor_interface = RobotSensorInterface(client, self.client_mutex, sensor_poll_rate, robot_prefix)
        self.navigation_interface = RobotNavigationInterface(client, self.client_mutex, robot_prefix)

    def start(self):
        x = threading.Thread(target=self.sensor_interface.start)
        y = threading.Thread(target=self.navigation_interface.start)
        x.start()
        y.start()
        rospy.spin()

if __name__ == '__main__':
    try:
        rospy.init_node('smads_ros_node', anonymous=False)
        platform = RobotType.JACKAL
        client = RobotType.platform_map[platform]

        platorm = rospy.get_param("~platform", 1)
        platform_prefix = rospy.get_param("~platform_prefix", "smads_platform")
        poll_rate = rospy.get_param("~sensor_poll_rate", 10)
        smadsros = SMADSROS(client, poll_rate, platform_prefix)
        smadsros.start()

    except rospy.ROSInterruptException:
        pass


#!/bin/bash
source /opt/ros/noetic/setup.bash
source /etc/ros/setup.bash

roslaunch smads_core architecture.ros.jackal.launch --wait

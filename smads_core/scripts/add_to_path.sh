#!/bin/bash
cd ../
echo "export ROS_PACKAGE_PATH=`pwd`:\$ROS_PACKAGE_PATH" >> ~/.bashrc
source ~/.bashrc

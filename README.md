# aaai_sss21 - SMADS - Short to Medium Range Autonomous Delivery System Meta Repository

This repository contains code for the various components introduced in the SMADS AAAI-SSS-21 proceedings titled "An Open-Source Framework for Last Mile Delivery with Heterogeneous Robots".

This repository contains submodules to public components, such as `smads_core` and `smads_robot_app_client` and modified versions of the code that provided the facilitated communication. These latter components are largely the same, but may have passwords or certificates removed for security purposes, which may prevent them from being able to be run out of the box.

Each software component is briefly described below.

SMADSBackend - The server backend code that is deployed on a machine to make it useful as a SMADS Management Server

SMADSClient - An interface for humans to interact with the SMADS system and order lemonade for delivery. In this case it is an iOS App written in Swift.

smads_core - Part of the Robot Interface, it translates and homogenizes robot data into a format that can be understood by the `smads_robot_app_client`

smads_robot_app_client - Part of the Robot Interface, this is run on each robot to facilitate communication between the robot and the SMADS Management Server.

If you utilize, extend or reference please reference the paper 

```
TO DO
```

## Usage
For details on how to use these components to deploy autonomous delivery robots please refer to the AAAI paper referenced above. 

Each component may have its own README that provides additional details on how to build, run and deploy that component.


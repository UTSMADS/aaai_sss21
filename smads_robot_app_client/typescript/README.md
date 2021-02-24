# SMADS Robot Client

This a node-js based client that is meant to run on the robot. It serves two primary functions:
1. Send status & localization updates to the remote App Server by subscribing to ROS messages and encoding them in the proper JSON form.
2. Handle commands from the remote App Server, and publish the appropriate commands on ROS.

### Dependencies
1. [Node.js](https://nodejs.org/en/download/package-manager/)
2. [yarn](https://classic.yarnpkg.com/en/docs/install)
3. ROS Melodic

### Building

#### `yarn install`
installs required node packages.

#### `yarn build`
compiles the current code

### Running

#### `yarn run run`
runs the robot client. Note that `roscore` should be up and running in order for the robot client to work.
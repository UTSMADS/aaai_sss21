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

### Running

#### `yarn dev`
runs the robot client using nodemon to watch for changes and reload. Note that `roscore` should be up and running in order for the robot client to work.

#### `yarn start`
runs the robot client. Note that `roscore` should be up and running in order for the robot client to work.

### Deployment
Before being deployed, the robot will need to have its own account on the backend with a unique `id`, `password`, and `name`. These data are loaded as credentials and are necessary for backend communication.

An example file exists in `credentials/robot.example.json`. Copy this file to one called `credentials/robot.json` and modify it with its unique entries. 
Existance of `robot.json` is *required* and the robot server will not run otherwise.

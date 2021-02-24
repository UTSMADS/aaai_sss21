const http = require("http");
const https = require("https");
const request = require("request");
const express = require("express");
const compression = require("compression");
const bodyParser = require("body-parser");
const axios = require("axios");
const yargs = require('yargs');

// initialize CLI flags
const argv = yargs
    .command('verbose', 'Increasing logging output', {
        verbosity: {
            description: 'the year to check for',
            alias: 'v',
            type: 'string',
        }
    })
    .help()
    .alias('help', 'h')
    .argv;

const verbose = argv._.includes('verbose')

// initialize rosnodejs
const rosnodejs = require("rosnodejs");
console.log("Loading packages...");
rosnodejs.loadAllPackages();
console.log("Done.");

let rosPublisher = undefined;
let token = "";
let jackalHardwareId = "";
let loggedIn = false;
let intervalId = 0;
let activeTrip = true;
let curTripId = 1590;
let preTrip = 0;
let postTrip = 0;
let lastNavStatus = 3;
let tripTypeHome = false; 
let startTime = new Date();

// maintain global current status
let currentStatus = {
  latitude: 0.0,
  longitude: 0.0,
  heading: 1.02,
  spotStatus: "available",
  chargeLevel: 0,
  timestamp : { 
    seconds: 0, 
    milliseconds: 0
  }
};

// maintain current navigation path
let navPath = [];
let pathProcessed = false;

// const instance= axios.create({baseURL: 'http://ut-smads.herokuapp.com'});
const instance = axios.create({
  //baseURL: "http://hypnotoad.csres.utexas.edu:8085",
  baseURL: "https://hypnotoad.csres.utexas.edu:8443",
});
// const instance= axios.create({baseURL: '10.0.0.31:8085'});

// load robot credentials
var robot_credentials = require('./credentials/robot.json');
const robot_status_topic = robot_credentials.topics.status.name;
const robot_status_message = robot_credentials.topics.status.message;

const sendRobotStatus = async () => {
  const config = {
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
  };
  if (!loggedIn) {
    console.log("Robot not logged in. Attempted to log in.");
    robotLogin();
  }
  try {
    const res = await instance.put(
      `/spots/`+robot_credentials.login.id+`/statusUpdate`,
      currentStatus,
      config
    );
    if (verbose){
	    console.log(currentStatus);
    }
    console.log("Status sent");
  } catch (e) {
    if (e.response.status === 503) {
      let publisher = rosPublisher;
      if (publisher !== undefined) {
        publisher.publish({
          x: currentStatus.longitude,
          y: currentStatus.longitude,
        });
      }
    }
    console.error(`Error sending server update ${e}`);
  }
};

const rosMessageHandler = (msg) => {
  if (verbose){
    console.log("Recieved ROS message");
  }
  // update current status attributes if they exist
  if (msg.hardware_id !== undefined) {
    jackalHardwareId = msg.hardware_id;
  }
  if (msg.point) {
    var timeDiff = new Date() - startTime;
    currentStatus.latitude = msg.point.x;
    currentStatus.longitude = msg.point.y;
    currentStatus.heading = msg.point.z;
    currentStatus.timestamp.seconds = msg.header.stamp.secs;
    currentStatus.timestamp.milliseconds = msg.header.stamp.nsecs;
  }
  if (msg.measured_battery) {
    currentStatus.chargeLevel = Math.floor(msg.measured_battery);
  }
};

const pathMsgHandler = (msg) => {
  console.log("Received path from navigation.");
  navPath = [];
  const poses = msg.poses;
  if (msg.poses) {
    msg.poses.map((pose) => {
      navPath = navPath.concat({
        latitude: pose.pose.position.x,
        longitude: pose.pose.position.y,
      });
    });
  }
  pathProcessed = true;
  console.log(navPath);
};

const navStatusMsgHandler = (msg) => {
  if (msg.status == 3 && lastNavStatus != msg.status) {
    if (tripTypeHome) {
      currentStatus.spotStatus = "atHome";
      console.log("Changing robot status to at home");
    } else {
      currentStatus.spotStatus = "dropoff";
      console.log("Changing robot status to dropoff");
    }
  }
  lastNavStatus = msg.status;
};

const sleep = (delay) => new Promise((resolve) => setTimeout(resolve, delay));

const receiveAppRequest = async (req, res) => {
  try {
    console.log("Received command from app backend:");
    console.log(req.body);
    res.set("Content-Type", "application/json");
    let publisher = rosPublisher;
    // publish 2D pose msg to ROS
    if (publisher !== undefined) {
      console.log(`Publishing ${publisher}`);
      publisher.publish({
        x: parseFloat(req.body.dropoffLocation.latitude),
        y: parseFloat(req.body.dropoffLocation.longitude),
        theta: 0.0,
      });
    }
    // update status of spot when a trip is received
    currentStatus.spotStatus = req.body.assignedSpot.status;
    curTripId = req.body.assignedSpot.id;
    
    // TODO better method needed to ensure navPath has been set
    await sleep(2000);
    pathProcessed = false;
    activeTrip = true;
    tripTypeHome = req.body.returningHome;
    console.log(navPath);
    const response = {
      locationPoints: navPath,
    };
    res.status(200).send(JSON.stringify(response));
  } catch (e) {
    console.log(e.toString());
    res.status(500).send("Exception: " + e.toString());
  }
};

const receiveHomeRequest = async (req, res) => {
  try {
    console.log("Received command from app backend:");
    console.log(req.body);
    res.set("Content-Type", "application/json");
    const response = {
      success : true,
    };
    let publisher = rosPublisher;
    // publish 2D pose msg to ROS
    if (publisher !== undefined) {
      console.log(`Publishing ${publisher}`);
      publisher.publish({
        x: parseFloat(req.body.dropoffLocation.latitude),
        y: parseFloat(req.body.dropoffLocation.longitude),
        theta: 0.0,
      });
    }
    // update status of spot when a trip is received
    currentStatus.spotStatus = req.body.assignedSpot.status;
    curTripId = req.body.assignedSpot.id;
    activeTrip = true;
    tripTypeHome = req.body.returningHome;
    res.status(200).send(JSON.stringify(response));
  } catch (e) {
    console.log(e.toString());
    res.status(500).send("Exception: " + e.toString());
  }
};

const cancelTrip = async (req, res) => {
  console.log(req);
  console.log(res);
  try {
    console.log("Cancelling trip.");
    res.set("Content-Type", "application/json");
    let publisher = rosPublisher;
    if (publisher !== undefined) {
      publisher.publish({
        x: currentStatus.longitude,
        y: currentStatus.longitude,
      });
    } else {
      res.status(200).send(JSON.stringify({ success: false }));
    }
    currentStatus.spotStatus = "available";
    activeTrip = false;
    res.status(200).send(JSON.stringify({ success: true }));
  } catch (e) {
    console.log(e);
    res.status(500).send(`Exception: ${e}`);
  }
};

const setSpotStatus = async (req, res) => {
  try {
    console.log("Changing robot status.");
    res.set("Content-Type", "application/json");
    currentStatus.spotStatus = req.body.status;
    res.status(200).send(JSON.stringify({ success: true }));
  } catch (e) {
    console.log(e);
    res.status(500).send(`Exception: ${e}`);
  }
};

const robotLogin = async () => {
  // login credentials
  const login = {
    username: robot_credentials.login.id,
    password: robot_credentials.login.password,
    name: robot_credentials.name,
  };

  try {
    console.log("logging in");
    const res = await instance.post(`/auth/login`, login);
    token = res.data.token;
    console.log(`Logged in. Authorization token: ${token}`);
    loggedIn = true;
  } catch (e) {
    console.error(`Error sending server update: ${e}`);
  }
};

const getTripFromApp = async () => {
  const config = {
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
  };

  try {
    const res = await instance.get(`/spots/0/activeTrip`, config);
    console.log(res.data);
    if (res.data.id !== null) {
      let x = rosPublisher;
      // publish 2D pose msg to ROS
      if (x !== undefined) {
        console.log(`Publishing ${x}`);
        x.publish({
          x: parseFloat(res.data.dropoffLocation.latitude),
          y: parseFloat(res.data.dropoffLocation.longitude),
          theta: 0.0,
        });
        clearInterval(intervalId);
      }
      activeTrip = true;
      //clearInterval(preTrip);
    }
  } catch (e) {
    console.error(e.message);
  }
};

const main = (rosNode) => {
  // Subscribe to robot's GPS localization topic
  const localizationSubscriber = rosNode.subscribe(
    "/smads/localization/out/gps",
    "geometry_msgs/PointStamped",
    rosMessageHandler,
    { queueSize: 1, throttleMs: 1000 }
  );
  rosPublisher = rosNode.advertise(
    "/smads/navigation/in/cmd",
    "geometry_msgs/Pose2D"
  );
  console.log(`Publisher: ${rosPublisher}`);
  // Subscribe to jackal status topic
  const statusSubscriber = rosNode.subscribe(
     robot_status_topic,
     robot_status_message,
    rosMessageHandler,
    { queueSize: 1, throttleMs: 1000 }
  );
  const pathSubscriber = rosNode.subscribe(
    "/smads/navigation/out/planned_path",
    "nav_msgs/Path",
    pathMsgHandler,
    { queueSize: 1, throttleMs: 1000 }
  );
  const navStatusSubscriber = rosNode.subscribe(
    "/smads/navigation/out/status",
    "actionlib_msgs/GoalStatus",
    navStatusMsgHandler,
    { queueSize: 1, throttleMs: 1000 }
  );

  if (!loggedIn) {
    robotLogin();
  }
  // regularly send updates to app backend
  preTrip = setInterval(sendRobotStatus, 1000);
  //postTrip = setInterval(sendRobotStatus, 10000);
  // poll to get a trip if it
  //intervalId = setInterval(getTripFromApp, 1000);
};

rosnodejs.initNode("/smads_app_client", { onTheFly: false }).then(main);

const robotAppClient = express();

robotAppClient.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  res.header(
    "Access-Control-Allow-Headers",
    "Origin, X-Requested-With, Content-Type, Accept"
  );
  next();
});

/*******
Testing API Calls
********/

const receivePathTestRequest = async (req, res) => {
  try {
    res.set("Content-Type", "application/json");
    path = [ ]
    path = path.concat({latitude: 30.28784230, longitude: -97.73702432,});
    path = path.concat({latitude: 30.28609770, longitude: -97.73666482,});
    path = path.concat({latitude: 30.28613810, longitude: -97.73597423,});
    console.log(path);
    const response = {
      locationPoints: path,
    };
    console.log(response);
    res.status(200).send(JSON.stringify(response));
  }  
  catch (e) {
    console.error(e.message);
  }

}

const receivePingTestRequest = async (req, res) => {
try {
    res.set("Content-Type", "application/json");
    const response = {
      success: true,
    };
    console.log(response);
    res.status(200).send(JSON.stringify(response));
  }  
  catch (e) {
    console.error(e.message);
  }
}



process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);

robotAppClient.use(bodyParser.json({ limit: "10mb" }));
robotAppClient.use(compression());

robotAppClient.post("/newTrip", receiveAppRequest);
robotAppClient.post("/sendSpotHome", receiveHomeRequest);
robotAppClient.post("/test/receivePath", receivePathTestRequest);
robotAppClient.post("/test/pingMe", receivePingTestRequest);

robotAppClient.put("/cancelledTrip", cancelTrip);
robotAppClient.put("/spotStatus", setSpotStatus);


// On shutdown, try to close any open trips
function shutdown() {  
  console.log('graceful shutdown express');

  const exitPayload = {
	"status": "outofservice"
  };
  const config = {
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
  };

  currentStatus.spotStatus = "outofservice";
  try {
    const res = instance.put(
      `/spots/`+robot_credentials.login.id+`/statusUpdate`,
      currentStatus,
      config
    );
  } catch(e) { }
  // /requests/trip_ID/complete
  /*if ( activeTrip ) {
    console.log('shutting down during trip. Sending complete trip request to backend');
    console.log('https://hypnotoad.csres.utexas.edu:8443/requests/'+curTripId+'/complete'); 
    request.put('https://hypnotoad.csres.utexas.edu:8443/requests/'+curTripId+'/complete');
    currentStatus.spotStatus = "available";
    activeTrip = false;
  }*/
  console.log("Exiting..");
  process.exit();
}


robotAppClient.listen(9143, () =>
  console.log("SMADS App client listening on port 9143")
);

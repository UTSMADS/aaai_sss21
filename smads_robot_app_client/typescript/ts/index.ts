import * as http from 'http'
import { Request, Response } from 'express';
import * as compression from 'compression'
import * as express from 'express';
import * as bodyParser from 'body-parser';


const rosnodejs = require('rosnodejs');
console.log("Loading packages...");
rosnodejs.loadAllPackages();
console.log("Done.");

let rosPublisher = undefined as undefined | any;

let token: String = ''; 
let jackalHardwareId: String = '';
let loggedIn: Boolean = false;
let intervalId : NodeJS.Timeout;
let activeTrip = false;

// maintain global current status
let currentStatus = {
  latitude: 0.0,
  longitude: 0.0,
  spotStatus: 'available',
  chargeLevel: 0
};

function sendUpdate() {
  const updateString = JSON.stringify(currentStatus);
  console.log(currentStatus)
  // An object of options to indicate where to put to
  var put_options = {
    host: "ut-smads.herokuapp.com",
    port: '80',
    path: '/spots/0/statusUpdate',
    method: 'PUT',
    headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(updateString),
        'Authorization': `Bearer ${token}`
    }
  };
  try {
    // Set up the request
    var put_req = http.request(put_options, function(res) {
      res.setEncoding('utf8');
    });
    put_req.on('error', function(e) {
      console.error("HTTP " + e);
    });
    // put the data
    put_req.write(updateString);
    put_req.end();
  } catch(e) {
    console.error('Error sending server update: ' + e);
  }
}

function rosTopicCallback(msg: any) {
  console.log('Recieved ROS message');
  // update current status attributes if they exist
  if (msg.hardware_id !== undefined) {
    jackalHardwareId = msg.hardware_id;
  }
  if (msg.latitude) {
    currentStatus.latitude = msg.latitude;
  }
  if (msg.longitude) {
    currentStatus.longitude = msg.longitude;
  }
  if (msg.measured_battery) {
    currentStatus.chargeLevel = Math.floor(msg.measured_battery);
  }
}

async function serverCallback(req: Request, res: Response) {
  try {
    console.log('Received command from app backend:');
    console.log(req.body);
    const response = {
      time: new Date(),
      response: 'Ok'
    };
    let x = rosPublisher as any;
    // publish 2D pose msg to ROS
    if (x !== undefined) {
      console.log(`Publishing ${x}`);
      x.publish({
        x: parseFloat(req.body.dropoffLocation.latitude),
        y: parseFloat(req.body.dropoffLocation.longitude),
        theta: 0.0
      });
    }
    // update status of spot when a trip is received 
    currentStatus.spotStatus = req.body.tripStatus;
    res.status(200).send(JSON.stringify(response));
  } catch(e) {
    console.log(e.toString);
    res.status(500).send("Exception: " + e.toString);
  }
}

function robotLogin() {
  // login credentials
  const login = {
    emailAddress: '0.3.9',
    password: 'smads_jackal',
    name: 'jackal'
  }

  const loginString = JSON.stringify(login);
  var post_options = {
    host: "ut-smads.herokuapp.com",
    port: '80',
    path: '/auth/login',
    method: 'POST',
    headers: {
        'Content-Type': 'application/json'
    }
  };
  try {
    // Set up the request
    var post_req = http.request(post_options, function(res) {
      res.setEncoding('utf8');
      res.on('data', function (chunk) {
        const response = JSON.parse(chunk);
        token = response.token;
        console.log(`Logged in. Authorization token: ${token}`)
      });
      res.on('end', () => {
        console.log("no more data");
      })
    });
    post_req.on('error', function(e) {
      console.error("HTTP " + e);
    });
    // post the data
    post_req.write(loginString);
    post_req.end();
    console.log("success");
    loggedIn = true;
  } catch(e) {
    console.error('Error sending server update: ' + e);
  }
}

function getTrip() {
  const get_options = {
    host: "ut-smads.herokuapp.com",
    port: '80',
    path: '/spots/0/activeTrip',
    headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
    }
  }
  http.get(get_options, (res) => {
    res.setEncoding('utf8');
    let rawData = '';
    res.on('data', (chunk) => { rawData += chunk; });
    res.on('end', () => {
      try {
        const parsedData = JSON.parse(rawData);
        console.log(parsedData);
        if (parsedData.id !== null) {
          let x = rosPublisher as any;
          // publish 2D pose msg to ROS
          if (x !== undefined) {
            console.log(`Publishing ${x}`);
            x.publish({
              x: parseFloat(parsedData.dropoffLocation.latitude),
              y: parseFloat(parsedData.dropoffLocation.longitude),
              theta: 0.0
            });
            clearInterval(intervalId);
          }
          activeTrip = true;
        } 
      } catch (e) {
        console.error(e.message);
      }
    });
  }).on('error', (e) => {
    console.error(`Got error: ${e.message}`);
  });
}

function main(rosNode: any) {
  // Subscribe to robot's GPS localization topic
  let localization_subscriber = rosNode.subscribe(
    "/gps/fix",
    "sensor_msgs/NavSatFix",
    rosTopicCallback,
    {queueSize: 1, throttleMs: 1000});
  rosPublisher = rosNode.advertise('/smads_waypoint/gps_goal', 'geometry_msgs/Pose2D');
  console.log(`Publisher: ${rosPublisher}`);
  // Subscribe to jackal status topic
  let status_subscriber = rosNode.subscribe(
    "/status",
    "jackal_msgs/Status",
    rosTopicCallback,
    {queueSize: 1, throttleMs: 1500});
  if (!loggedIn) {
    robotLogin();
  }
  // regularly send updates to app backend
  setInterval(() => {
    sendUpdate();
  }, 1000);
  // poll to get a trip if it 
  // intervalId = setInterval(() => {
  //  getTrip();
  // }, 1000)
}

rosnodejs.initNode('/smads_app_client',{ onTheFly: false }).then(main);

export const callbackServer = express();

callbackServer.use(function(req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  next();
});
callbackServer.use(bodyParser.json({ limit: '10mb' }));
callbackServer.use(compression());
callbackServer.post('/newTrip', serverCallback);
callbackServer.listen(9143, () => console.log('SMADS App client listening on port 9143'))

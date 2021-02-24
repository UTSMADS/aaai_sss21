const fs = require("fs");
const http = require("http");

const tolerance = 0.0001;
let coodinates;
let filteredCoordinates = [];
let index = 0;
const interval = 1000;

const baseURL = "https://ut-smads.herokuapp.com";
const port = "8080";
const endpoint = "/spots/3/statusUpdate";

const loadData = (cb) => {
	fs.readFile("./gps.txt", "utf8", (err,data) => {
		if(err){
			return console.log(err)
		}
		coordinates = data.split("\n");

		for (i = 0; i < coordinates.length - 1; i++) {
			const temp = coordinates[i].trim();
			const coords = temp.split(" ");
			const latitude = coords[0];
			const longitude = coords[1];
			const coord = { latitude, longitude };

			if (filteredCoordinates.length == 0) {
				filteredCoordinates.push(coord);
			} else {
				const lastFilteredCoordinate = filteredCoordinates[filteredCoordinates.length - 1];
				if ((Math.abs(coord.latitude - lastFilteredCoordinate.latitude) > tolerance) || (Math.abs(coord.longitude - lastFilteredCoordinate.longitude) > tolerance)) {
					filteredCoordinates.push(coord);
				}
			}
		}
		console.log(filteredCoordinates);
		console.log(filteredCoordinates.length);
		cb();
	});
};

const pingBackend = () => {

	const body = {};
	body.latitude = filteredCoordinates[index].latitude;
	body.longitude = filteredCoordinates[index].longitude;
	if (index == 0) {
		body.spotStatus	= "pickup";
	} else if (index == filteredCoordinates.length - 1) {
		body.spotStatus = "dropoff";
	} else {
		body.spotStatus = "enroute";
	}
	body.chargeLevel = 99.0;

	const bodyString = JSON.stringify(body);
	const length = Buffer.byteLength(bodyString);
	const config = {
		host: baseURL, 
		port: port,
		path: endpoint, 
		method: "PUT",
		headers: {
			"Content-Type": "application/json",
			"Content-Length": length,
			"Authorization": "mySECRET"
		}
	};

	const postRequest = http.request(config, (res) => {
		res.setEncoding("utf8");
		res.on("data", d => console.log("received: " + d));
		res.on("end", () => {
			console.log(index++);
			if (index < filteredCoordinates.length) {
				setTimeout(pingBackend, interval);
			}			
		});
	});
	postRequest.write(JSON.stringify(body));
	postRequest.end();
};

loadData(() => {
	pingBackend();
});








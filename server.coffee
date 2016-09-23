# parse command line arguments
# i.e. --port 3000
argv = require('yargs').argv;
port = argv.port || 1234

# Express is the base web server
# body-parser is used to read data from the body of POST requests
express = require 'express'
bodyParser = require 'body-parser'
app = express();
app.use bodyParser.json()
app.use bodyParser.urlencoded()

# useful utils
_ = require 'underscore'

# The GM API is consumed
GM = require("maxp-smartcar-gm").GM

# When an error is raised in a promise, log the error and send it as a response
errFn = (res) -> (err) ->
  console.dir err
  res.send err

# Route to get basic info about a vehicle
app.get '/vehicles/:id', (req, res)  ->
  GM.endpoints.getVehicleInfoService(req.params.id)
  .then (GmResponse) ->
    smartcarResponse =
      vin: GmResponse['data']['vin']['value']
      color: GmResponse['data']['color']['value']
      doorCount: if (GmResponse['data']['fourDoorSedan']['value'] == 'True') then 4 else 2
      driveTrain: GmResponse['data']['driveTrain']['value']
    res.send smartcarResponse
  .catch errFn(res)
  
# Route to get info about a vehicle security (i.e. are the doors locked)
app.get '/vehicles/:id/doors', (req, res) ->
  GM.endpoints.getSecurityStatus(req.params.id)
  .then (GmResponse) ->
    smartcarResponse = _.map GmResponse['data']['doors']['values'], (obj) ->
      location: obj['location']['value']
      locked: obj['locked']['value'] == "True"
    res.send smartcarResponse
  .catch errFn(res)

# Route to see a vehicle's fuel level (will return null if the data isn't available)
app.get '/vehicles/:id/fuel', (req, res)  ->
  GM.endpoints.getEnergyService(req.params.id)
  .then (GmResponse) ->
    smartcarResponse =
      percent: Math.round(parseInt GmResponse['data']['tankLevel']['value'])
    res.send smartcarResponse
  .catch errFn(res)

# Route to see a vehicle's battery level (will return null if the data isn't available)
app.get '/vehicles/:id/battery', (req, res)  ->
  GM.endpoints.getEnergyService(req.params.id)
  .then (GmResponse) ->
    smartcarResponse =
      percent: Math.round(parseInt GmResponse['data']['batteryLevel']['value'])
    res.send smartcarResponse
  .catch errFn(res)

# Route to start or stop the engine
app.post '/vehicles/:id/engine', (req, res)  ->
  command = req.body.command
  GmResponsePromise = if command == "START" then GM.endpoints.startEngine(req.params.id)
  else if command == "STOP" then GM.endpoints.stopEngine(req.params.id)
  GmResponsePromise.then (GmResponse) ->
    res.send
      status: if (GmResponse['actionResult']['status'] == "EXECUTED") then "success" else "error"
  .catch errFn(res)

# Start the express app
app.listen port, () ->
  console.log("Example app listening on port #{port}");

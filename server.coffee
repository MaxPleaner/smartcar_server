argv = require('yargs').argv;
express = require 'express'
_ = require 'underscore'
bodyParser = require 'body-parser'
app = express();
app.use bodyParser.json()
app.use bodyParser.urlencoded()
port = argv.port || 1234
GM = require("../smartcar/dist/main.js").GM

errFn = (res) -> (err) ->
  console.dir err
  res.send err

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
  
app.get '/vehicles/:id/doors', (req, res) ->
  GM.endpoints.getSecurityStatus(req.params.id)
  .then (GmResponse) ->
    smartcarResponse = _.map GmResponse['data']['doors']['values'], (obj) ->
      location: obj['location']['value']
      locked: obj['locked']['value'] == "True"
    res.send smartcarResponse
  .catch errFn(res)
  
app.get '/vehicles/:id/fuel', (req, res)  ->
  GM.endpoints.getEnergyService(req.params.id)
  .then (GmResponse) ->
    smartcarResponse =
      percent: Math.round(parseInt GmResponse['data']['tankLevel']['value'])
    res.send smartcarResponse
  .catch errFn(res)
  
app.get '/vehicles/:id/battery', (req, res)  ->
  GM.endpoints.getEnergyService(req.params.id)
  .then (GmResponse) ->
    parsedVal = Math.round(parseInt GmResponse['data']['batteryLevel']['value'])
    smartcarResponse =
      # sometimes the GM response is NaN; send 0 in this case
      percent: if parsedVal then parsedVal else 0
    res.send smartcarResponse
  .catch errFn(res)
  
app.post '/vehicles/:id/engine', (req, res)  ->
  command = req.body.command
  GmResponsePromise = if command == "START" then GM.endpoints.startEngine(req.params.id)
  else if command == "STOP" then GM.endpoints.stopEngine(req.params.id)
  GmResponsePromise.then (GmResponse) ->
    res.send
      status: if (GmResponse['actionResult']['status'] == "EXECUTED") then "success" else "error"
  .catch errFn(res)
  
app.listen port, () ->
  console.log("Example app listening on port #{port}");
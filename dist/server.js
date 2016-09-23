// Generated by CoffeeScript 1.10.0
(function() {
  var GM, _, app, argv, bodyParser, errFn, express, port;

  argv = require('yargs').argv;

  express = require('express');

  _ = require('underscore');

  bodyParser = require('body-parser');

  app = express();

  app.use(bodyParser.json());

  app.use(bodyParser.urlencoded());

  port = argv.port || 1234;

  GM = require("../smartcar/dist/main.js").GM;

  errFn = function(res) {
    return function(err) {
      console.dir(err);
      return res.send(err);
    };
  };

  app.get('/vehicles/:id', function(req, res) {
    return GM.endpoints.getVehicleInfoService(req.params.id).then(function(GmResponse) {
      var smartcarResponse;
      smartcarResponse = {
        vin: GmResponse['data']['vin']['value'],
        color: GmResponse['data']['color']['value'],
        doorCount: GmResponse['data']['fourDoorSedan']['value'] === 'True' ? 4 : 2,
        driveTrain: GmResponse['data']['driveTrain']['value']
      };
      return res.send(smartcarResponse);
    })["catch"](errFn(res));
  });

  app.get('/vehicles/:id/doors', function(req, res) {
    return GM.endpoints.getSecurityStatus(req.params.id).then(function(GmResponse) {
      var smartcarResponse;
      smartcarResponse = _.map(GmResponse['data']['doors']['values'], function(obj) {
        return {
          location: obj['location']['value'],
          locked: obj['locked']['value'] === "True"
        };
      });
      return res.send(smartcarResponse);
    })["catch"](errFn(res));
  });

  app.get('/vehicles/:id/fuel', function(req, res) {
    return GM.endpoints.getEnergyService(req.params.id).then(function(GmResponse) {
      var smartcarResponse;
      smartcarResponse = {
        percent: Math.round(parseInt(GmResponse['data']['tankLevel']['value']))
      };
      return res.send(smartcarResponse);
    })["catch"](errFn(res));
  });

  app.get('/vehicles/:id/battery', function(req, res) {
    return GM.endpoints.getEnergyService(req.params.id).then(function(GmResponse) {
      var parsedVal, smartcarResponse;
      parsedVal = Math.round(parseInt(GmResponse['data']['batteryLevel']['value']));
      smartcarResponse = {
        percent: parsedVal ? parsedVal : 0
      };
      return res.send(smartcarResponse);
    })["catch"](errFn(res));
  });

  app.post('/vehicles/:id/engine', function(req, res) {
    var GmResponsePromise, command;
    command = req.body.command;
    GmResponsePromise = command === "START" ? GM.endpoints.startEngine(req.params.id) : command === "STOP" ? GM.endpoints.stopEngine(req.params.id) : void 0;
    return GmResponsePromise.then(function(GmResponse) {
      return res.send({
        status: GmResponse['actionResult']['status'] === "EXECUTED" ? "success" : "error"
      });
    })["catch"](errFn(res));
  });

  app.listen(port, function() {
    return console.log("Example app listening on port " + port);
  });

}).call(this);

import 'package:location/location.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:location/location.dart';
import 'package:camera/camera.dart';
import 'package:light/light.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:projekt_app/sendData.dart';
import 'package:projekt_app/main.dart';

// class ThemeNotifier with ChangeNotifier {
//   bool _isDarkMode = false;
//
//   bool get isDarkMode => _isDarkMode;
//
//   void updateTheme(bool isDarkMode) {
//     _isDarkMode = isDarkMode;
//     notifyListeners();
//   }
// }


class DataSend extends StatefulWidget {
  const DataSend({Key? key, required this.title, required this.ip}) : super(key: key);

  final String title;
  final String ip;

  @override
  State<DataSend> createState() => _DataSendState();
}

class _DataSendState extends State<DataSend> {
  int _user = 0; //update on login
  LocationData? _startLocation;
  LocationData? _endLocation;
  List<double> _accelerometerListX = [];
  List<double> _accelerometerListY = [];
  List<double> _accelerometerListZ = [];
  List<double> _userAccelerometerListX = [];
  List<double> _userAccelerometerListY = [];
  List<double> _userAccelerometerListZ = [];
  List<double> _gyroscopeListX = [];
  List<double> _gyroscopeListY = [];
  List<double> _gyroscopeListZ = [];
  // List<double> _magnetometerList = [];
  List<double> _accelerometerValues = [0,0,0];
  List<double> _userAccelerometerValues = [0,0,0];
  List<double> _gyroscopeValues = [0,0,0];
  // List<double> _magnetometerValues = [0,0,0];
  int _lightIntensity = 0;
  late ThemeNotifier _themeNotifier;
  late Light _light;
  int _readCount = 0;
  double latDelta = 0;
  double longDelta = 0;

  Map<String, dynamic> _readData = {
    'capturedBy': 0,
    'latitude_start': 0,
    'longitude_start': 0,
    'latitude_end': 0,
    'longitude_end': 0,
    'captureDate': DateTime.now().toIso8601String(),
    'accelerometerX': 0,
    'accelerometerY': 0,
    'accelerometerZ': 0,
    'userAccelerometerX': 0,
    'userAccelerometerY': 0,
    'userAccelerometerZ': 0,
    'gyroscopeX': 0,
    'gyroscopeY': 0,
    'gyroscopeZ': 0,
    'lightIntensity': 0,
  };



  @override
  void initState() {
    super.initState();
    _light = Light();
    _initLightSensor();
    _initSensors();
    _getLocation();
    Timer.periodic(Duration(seconds: 1), (Timer t) => readData());

  }

  void _initLightSensor() async {
    try {
      _light.lightSensorStream.listen((lightIntensity) {
        setState(() {
          _lightIntensity = lightIntensity;
          _updateTheme();
        });
      });
    } catch (e) {
      print('Light sensor not available: $e');
    }
  }
  void _initSensors() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
      });
    });

    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
      });
    });

    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    });

    // magnetometerEvents.listen((MagnetometerEvent event) {
    //   setState(() {
    //     _magnetometerValues = <double>[event.x, event.y, event.z];
    //   });
    // });
  }
  void _getLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      _startLocation = _locationData;
    });
  }
  void _incrementCounter() {
    setState(() {
      // _counter++;
    });
    // sendCaptureData();
  }



  void _updateTheme() {
    bool isDarkMode = _lightIntensity < 50.0;
    _themeNotifier.updateTheme(isDarkMode);
  }

  void addData(){
    _accelerometerListX.add(_accelerometerValues[0]);
    _accelerometerListY.add(_accelerometerValues[1]);
    _accelerometerListZ.add(_accelerometerValues[2]);
    _userAccelerometerListX.add(_userAccelerometerValues[0]);
    _userAccelerometerListY.add(_userAccelerometerValues[1]);
    _userAccelerometerListZ.add(_userAccelerometerValues[2]);
    _gyroscopeListX.add(_gyroscopeValues[0]);
    _gyroscopeListY.add(_gyroscopeValues[1]);
    _gyroscopeListZ.add(_gyroscopeValues[2]);
    setState(() {  });

  }

  void readData(){
    // Pošiljanje podatkov:
    // vsakih 10s, 2x lokacija vsakih 5s
    // vsako sekundo zajameš vse senzorje in dodas v array

    if(_readCount == 5){
      _getLocation();
      _endLocation = _startLocation;
      addData();
    }else if(_readCount == 10){
      addData();
      _getLocation();
      //send + null

      _readData = {
        'capturedBy': _user,
        'latitude_start': _endLocation?.latitude,
        'longitude_start': _endLocation?.longitude,
        'latitude_end': _startLocation?.latitude,
        'longitude_end': _startLocation?.longitude,
        'captureDate': DateTime.now().toIso8601String(),
        'accelerometerX': _accelerometerListX,
        'accelerometerY': _accelerometerListY,
        'accelerometerZ': _accelerometerListZ,
        'userAccelerometerX': _userAccelerometerListX,
        'userAccelerometerY': _userAccelerometerListY,
        'userAccelerometerZ': _userAccelerometerListZ,
        'gyroscopeX': _gyroscopeListX,
        'gyroscopeY': _gyroscopeListY,
        'gyroscopeZ': _gyroscopeListZ,
        'lightIntensity': _lightIntensity,
      };

      longDelta = (_startLocation!.longitude! - _endLocation!.longitude!).abs();
      latDelta = (_startLocation!.latitude! - _endLocation!.latitude!).abs();
      print("Long/lat delta:$longDelta / $latDelta");
      if(longDelta > 0.00001 || latDelta > 0.00001){
        sendCaptureData(_readData, widget.ip);
      }

      _accelerometerListX = [];
      _accelerometerListY = [];
      _accelerometerListZ = [];
      _userAccelerometerListX = [];
      _userAccelerometerListY = [];
      _userAccelerometerListZ = [];
      _gyroscopeListX = [];
      _gyroscopeListY = [];
      _gyroscopeListZ = [];
      _readCount = 0;

    }else{
      addData();
    }
    print("Read count:$_readCount");
    _readCount++;
  }



  @override
  Widget build(BuildContext context) {
    _themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('User: ${_user}'),
            SizedBox(height: 16.0),
            Text('Start long/lat'),
            if(_startLocation != null)
              Text('${_startLocation?.longitude} / ${_startLocation?.latitude}'),
            SizedBox(height: 16.0),
            Text('End long/lat'),
            if(_endLocation != null)
              Text('${_endLocation?.longitude} / ${_endLocation?.latitude}'),
            SizedBox(height: 16.0),


            Text('Accelerometer Data'),
            if(_accelerometerListX.isNotEmpty)
              Text('X: ${_accelerometerListX.last}'),
            if(_accelerometerListY.isNotEmpty)
              Text('Y: ${_accelerometerListY.last}'),
            if(_accelerometerListZ.isNotEmpty)
              Text('Z: ${_accelerometerListZ.last}'),
            SizedBox(height: 16.0),

            Text('User accelerometer Data'),
            if(_userAccelerometerListX.isNotEmpty)
              Text('X: ${_userAccelerometerListX.last}'),
            if(_userAccelerometerListY.isNotEmpty)
              Text('Y: ${_userAccelerometerListY.last}'),
            if(_userAccelerometerListZ.isNotEmpty)
              Text('Z: ${_userAccelerometerListZ.last}'),
            SizedBox(height: 16.0),

            Text('Gyroscope Data'),
            if(_gyroscopeListX.isNotEmpty)
              Text('X: ${_gyroscopeListX.last}'),
            if(_gyroscopeListY.isNotEmpty)
              Text('Y: ${_gyroscopeListY.last}'),
            if(_gyroscopeListZ.isNotEmpty)
              Text('Z: ${_gyroscopeListZ.last}'),
            SizedBox(height: 16.0),

            Text('Light intensity'),
            if(_lightIntensity != null)
              Text('${_lightIntensity}'),
            SizedBox(height: 16.0),



          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}

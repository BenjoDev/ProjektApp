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

class ThemeNotifier with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void updateTheme(bool isDarkMode) {
    _isDarkMode = isDarkMode;
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: themeNotifier.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),
      home: const FirstPage(),
      routes: {
        '/second': (context) => const MyHomePage(title: 'Flutter Demo Home Page'),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
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
  List<double> _magnetometerList = [];
  List<double> _accelerometerValues = [0,0,0];
  List<double> _userAccelerometerValues = [0,0,0];
  List<double> _gyroscopeValues = [0,0,0];
  List<double> _magnetometerValues = [0,0,0];
  int _lightIntensity = 0;
  late ThemeNotifier _themeNotifier;
  late Light _light;
  int _readCount = 0;

  Map<String, dynamic> _readData = { };



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

    magnetometerEvents.listen((MagnetometerEvent event) {
      setState(() {
        _magnetometerValues = <double>[event.x, event.y, event.z];
      });
    });
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
      _counter++;
    });
    // sendCaptureData();
  }

  // Pošiljanje podatkov:
  // vsakih 10s, 2x lokacija vsakih 5s
  // vsako sekundo zajameš vse senzorje in dodas v array
  // 'capturedBy' : Number,
  // 	'latitude_start' : Number,
  // 	'longitude_start' : Number,
  // 	'latitude_end' : Number,
  // 	'longitude_end' : Number,
  // 	'captureDate' : Date,
  // 	'accelerometerX': [Number],
  // 	'accelerometerY': [Number],
  // 	'accelerometerZ': [Number],
  // 	'userAccelerometerX': [Number],
  // 	'userAccelerometerY': [Number],
  // 	'userAccelerometerZ': [Number],
  // 	'gyroscopeX': [Number],
  // 	'gyroscopeY': [Number],
  // 	'gyroscopeZ': [Number],
  // 	'lightIntensity': Number,
  // 	'roadQuality': Number

  Future<void> sendCaptureData() async {
    // Define the capture data to send

    print("Sending!!!");
    // Convert capture data to JSON
    String jsonData = jsonEncode(_readData);
    // String jsonData = jsonEncode(_readData);

    try {
      // Send a POST request to the API endpoint
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3001/phoneData'),
        headers: {'Content-Type': 'application/json'},
        body: jsonData,
      );

      if (response.statusCode == 201) {
        // Capture data successfully sent
        print('Capture data sent successfully');
      } else {
        // Handle error if capture data sending failed
        print('Failed to send capture data: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any exceptions or network errors
      print('Error sending capture data: $error');
    }
  }

  void _updateTheme() {
    bool isDarkMode = _lightIntensity < 50.0;
    _themeNotifier.updateTheme(isDarkMode);
  }

  void readData(){
    if(_readCount == 5){
      _getLocation();
      _endLocation = _startLocation;
    }else if(_readCount == 10){
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

      sendCaptureData();

      _accelerometerListX = [];
      _accelerometerListY = [];
      _accelerometerListZ = [];
      _userAccelerometerListX = [];
      _userAccelerometerListY = [];
      _userAccelerometerListZ = [];
      _gyroscopeListX = [];
      _gyroscopeListY = [];
      _gyroscopeListZ = [];
      setState(() {  });
      _readCount = 0;

    }else{
      _accelerometerListX.add(_accelerometerValues[0]);
      _accelerometerListY.add(_accelerometerValues[1]);
      _accelerometerListZ.add(_accelerometerValues[2]);
      _userAccelerometerListX.add(_userAccelerometerValues[0]);
      _userAccelerometerListY.add(_userAccelerometerValues[1]);
      _userAccelerometerListZ.add(_userAccelerometerValues[2]);
      _gyroscopeListX.add(_gyroscopeValues[0]);
      _gyroscopeListY.add(_gyroscopeValues[1]);
      _gyroscopeListZ.add(_gyroscopeValues[2]);

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
            // const Text(
            //   'You have pushed the button this many times:',
            // ),
            // Text(
            //   '$_counter',
            // ),
            SizedBox(height: 16.0),
            // Text(_readData.toString())
            // Text('Accelerometer Data'),
            // Text('X: ${_accelerometerValues[0]}'),
            // Text('Y: ${_accelerometerValues[1]}'),
            // Text('Z: ${_accelerometerValues[2]}'),
            // SizedBox(height: 16.0),
            // Text('User Accelerometer Data'),
            // Text('X: ${_userAccelerometerValues[0]}'),
            // Text('Y: ${_userAccelerometerValues[1]}'),
            // Text('Z: ${_userAccelerometerValues[2]}'),
            // SizedBox(height: 16.0),
            // Text('Gyroscope Data'),
            // Text('X: ${_gyroscopeValues[0]}'),
            // Text('Y: ${_gyroscopeValues[1]}'),
            // Text('Z: ${_gyroscopeValues[2]}'),
            // SizedBox(height: 16.0),
            // Text('Magnetometer Data'),
            // Text('X: ${_magnetometerValues[0]}'),
            // Text('Y: ${_magnetometerValues[1]}'),
            // Text('Z: ${_magnetometerValues[2]}'),
            // SizedBox(height: 16.0),
            // if (_startLocation != null) ...[
            //   Text('Latitude: ${_startLocation!.latitude}'),
            //   Text('Longitude: ${_startLocation!.longitude}'),
            // ] else
            //   Text('Location data unavailable'),
            // SizedBox(height: 16.0),
            // Text('Light Intensity: $_lightIntensity'),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  String name = "";
  String final_response = "";

  File? selectedImage;
  String? message = "";

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _cameraController = CameraController(_cameras![1], ResolutionPreset.medium);
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> takePicture() async {
    if (_cameraController!.value.isInitialized) {
      message = "Processing";
      final imagePath = await _cameraController!.takePicture();
      selectedImage = File(imagePath.path);
      setState(() {

      });
      // uploadImage();
      Navigator.pushNamed(context, '/second');

      // Handle the captured image path, e.g., display it in an ImageView
      print('Image Path: ${imagePath.path}');
    }
  }

  uploadImage() async{
    final response0 = await http.post(Uri.parse('https://8bc4-89-143-87-222.eu.ngrok.io/name'), body: json.encode({'name' : '1'})); // 0 = Benjamin, 1 = Žan

    final request = http.MultipartRequest("POST", Uri.parse('https://8bc4-89-143-87-222.eu.ngrok.io/upload'));
    final headers = {"Content-type": "multipart/form-data"};
    request.files.add(
        http.MultipartFile('image', selectedImage!.readAsBytes().asStream(), selectedImage!.lengthSync(),
            filename: selectedImage!.path.split("/").last)
    );

    request.headers.addAll(headers);
    final response = await request.send();
    http.Response res = await http.Response.fromStream(response);
    try {
      final resJson = jsonDecode(res.body);
      message = resJson['message'];

      if(message == "0"){
        Navigator.pushNamed(context, '/second');
      }
      else {
        message = "not the right person";
      }
      setState(() {

      });
      // Process the response JSON
    } catch (e) {
      print('Error decoding JSON: $e');
      message = 'Error decoding JSON: $e';
      setState(() {

      });
      // Handle the error or provide a fallback response
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isCameraInitialized)
              SizedBox(
                width: 300,
                height: 450,
                child: CameraPreview(_cameraController!),
              ),
            ElevatedButton(
              onPressed: _isCameraInitialized ? takePicture : null,
              child: Text('Take Picture'),
            ),
            Text(message!),
          ],
        ),
      ),
    );
  }
}

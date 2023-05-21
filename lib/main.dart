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
  List<double> _accelerometerValues = [0, 0, 0];
  List<double> _userAccelerometerValues = [0, 0, 0];
  List<double> _gyroscopeValues = [0, 0, 0];
  List<double> _magnetometerValues = [0, 0, 0];
  LocationData? _currentLocation;
  int _lightIntensity = 0;
  late ThemeNotifier _themeNotifier;
  late Light _light;



  @override
  void initState() {
    super.initState();
    _light = Light();
    _initLightSensor();
    _initSensors();
    _getLocation();
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
      _currentLocation = _locationData;
    });
  }
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }
  void _updateTheme() {
    bool isDarkMode = _lightIntensity < 50.0;
    _themeNotifier.updateTheme(isDarkMode);
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
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 16.0),
            Text('Accelerometer Data'),
            Text('X: ${_accelerometerValues[0]}'),
            Text('Y: ${_accelerometerValues[1]}'),
            Text('Z: ${_accelerometerValues[2]}'),
            SizedBox(height: 16.0),
            Text('User Accelerometer Data'),
            Text('X: ${_userAccelerometerValues[0]}'),
            Text('Y: ${_userAccelerometerValues[1]}'),
            Text('Z: ${_userAccelerometerValues[2]}'),
            SizedBox(height: 16.0),
            Text('Gyroscope Data'),
            Text('X: ${_gyroscopeValues[0]}'),
            Text('Y: ${_gyroscopeValues[1]}'),
            Text('Z: ${_gyroscopeValues[2]}'),
            SizedBox(height: 16.0),
            Text('Magnetometer Data'),
            Text('X: ${_magnetometerValues[0]}'),
            Text('Y: ${_magnetometerValues[1]}'),
            Text('Z: ${_magnetometerValues[2]}'),
            SizedBox(height: 16.0),
            if (_currentLocation != null) ...[
              Text('Latitude: ${_currentLocation!.latitude}'),
              Text('Longitude: ${_currentLocation!.longitude}'),
            ] else
              Text('Location data unavailable'),
            SizedBox(height: 16.0),
            Text('Light Intensity: $_lightIntensity'),

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
      uploadImage();
      // Handle the captured image path, e.g., display it in an ImageView
      print('Image Path: ${imagePath.path}');
    }
  }

  uploadImage() async{
    final request = http.MultipartRequest("POST", Uri.parse('https://3129-89-143-87-222.eu.ngrok.io/upload'));

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
      setState(() {

      });
      if(message == "0"){
        Navigator.pushNamed(context, '/second');
      }

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

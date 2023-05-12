import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:location/location.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SecondPage(),
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

  @override
  void initState() {
    super.initState();
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

    _getLocation();
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

  @override
  Widget build(BuildContext context) {
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
    style: Theme.of(context).textTheme.headline6
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

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  late File _capturedImage;

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
      final imagePath = await _cameraController!.takePicture();
      // Handle the captured image path, e.g., display it in an ImageView
      print('Image Path: ${imagePath.path}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Page'),
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
            ElevatedButton(
              onPressed: () {
              Navigator.pushNamed(context, '/second');
            },
              child: Text('Go to Second Page'),
            ),
          ],
        ),
      ),
    );
  }
}

// class SecondPage extends StatelessWidget {
//   const SecondPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('First Page'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             Navigator.pushNamed(context, '/second');
//           },
//           child: Text('Go to Second Page'),
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:sensors_plus/sensors_plus.dart';
// import 'package:location/location.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//   List<double> _accelerometerValues = [0, 0, 0];
//   List<double> _userAccelerometerValues = [0, 0, 0];
//   List<double> _gyroscopeValues = [0, 0, 0];
//   List<double> _magnetometerValues = [0, 0, 0];
//   LocationData? _currentLocation;
//
//   @override
//   void initState() {
//     super.initState();
//     accelerometerEvents.listen((AccelerometerEvent event) {
//       setState(() {
//         _accelerometerValues = <double>[event.x, event.y, event.z];
//       });
//     });
//
//     userAccelerometerEvents.listen((UserAccelerometerEvent event) {
//       setState(() {
//         _userAccelerometerValues = <double>[event.x, event.y, event.z];
//       });
//     });
//
//     gyroscopeEvents.listen((GyroscopeEvent event) {
//       setState(() {
//         _gyroscopeValues = <double>[event.x, event.y, event.z];
//       });
//     });
//
//     magnetometerEvents.listen((MagnetometerEvent event) {
//       setState(() {
//         _magnetometerValues = <double>[event.x, event.y, event.z];
//       });
//     });
//
//     _getLocation();
//   }
//
//   void _getLocation() async {
//     Location location = Location();
//
//     bool _serviceEnabled;
//     PermissionStatus _permissionGranted;
//     LocationData _locationData;
//
//     _serviceEnabled = await location.serviceEnabled();
//     if (!_serviceEnabled) {
//       _serviceEnabled = await location.requestService();
//       if (!_serviceEnabled) {
//         return;
//       }
//     }
//
//     _permissionGranted = await location.hasPermission();
//     if (_permissionGranted == PermissionStatus.denied) {
//       _permissionGranted = await location.requestPermission();
//       if (_permissionGranted != PermissionStatus.granted) {
//         return;
//       }
//     }
//
//     _locationData = await location.getLocation();
//     setState(() {
//       _currentLocation = _locationData;
//     });
//   }
//
//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//       child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: <Widget>[
//     const Text(
//     'You have pushed the button this many times:',
//     ),
//     Text(
//     '$_counter',
//     style: Theme.of(context).textTheme.headline6,
//     ),
//     SizedBox(height: 16.0),
//     Text('Accelerometer Data'),
//     Text('X: ${_accelerometerValues[0]}'),
//         Text('Y: ${_accelerometerValues[1]}'),
//         Text('Z: ${_accelerometerValues[2]}'),
//         SizedBox(height: 16.0),
//         Text('User Accelerometer Data'),
//         Text('X: ${_userAccelerometerValues[0]}'),
//         Text('Y: ${_userAccelerometerValues[1]}'),
//         Text('Z: ${_userAccelerometerValues[2]}'),
//         SizedBox(height: 16.0),
//         Text('Gyroscope Data'),
//         Text('X: ${_gyroscopeValues[0]}'),
//         Text('Y: ${_gyroscopeValues[1]}'),
//         Text('Z: ${_gyroscopeValues[2]}'),
//         SizedBox(height: 16.0),
//         Text('Magnetometer Data'),
//         Text('X: ${_magnetometerValues[0]}'),
//         Text('Y: ${_magnetometerValues[1]}'),
//         Text('Z: ${_magnetometerValues[2]}'),
//         SizedBox(height: 16.0),
//         if (_currentLocation != null) ...[
//           Text('Latitude: ${_currentLocation!.latitude}'),
//           Text('Longitude: ${_currentLocation!.longitude}'),
//         ] else
//           Text('Location data unavailable'),
//       ],
//       ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

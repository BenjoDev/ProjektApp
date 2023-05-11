import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:location/location.dart';

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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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




// import 'package:flutter/material.dart';
// import 'package:sensors_plus/sensors_plus.dart';
//
// void main() {
//   runApp(const MyApp());
//   accelerometerEvents.listen((AccelerometerEvent event) {
//     print(event);
//   });
// // [AccelerometerEvent (x: 0.0, y: 9.8, z: 0.0)]
//
//   userAccelerometerEvents.listen((UserAccelerometerEvent event) {
//     print(event);
//   });
// // [UserAccelerometerEvent (x: 0.0, y: 0.0, z: 0.0)]
//
//   gyroscopeEvents.listen((GyroscopeEvent event) {
//     print(event);
//   });
// // [GyroscopeEvent (x: 0.0, y: 0.0, z: 0.0)]
//
//   magnetometerEvents.listen((MagnetometerEvent event) {
//     print(event);
//   });
// // [MagnetometerEvent (x: -23.6, y: 6.2, z: -34.9)]
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.
//
//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
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
//
//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Invoke "debug painting" (press "p" in the console, choose the
//           // "Toggle Debug Paint" action from the Flutter Inspector in Android
//           // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
//           // to see the wireframe for each widget.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }

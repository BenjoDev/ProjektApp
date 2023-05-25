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
import 'package:projekt_app/dataSend.dart';
import 'package:projekt_app/faceRecognition.dart';

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
  MyApp({Key? key}) : super(key: key);

  String ip = "http://192.168.137.1";
  // String ip = "http://10.0.2.2";
  String user_id = "null";

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: themeNotifier.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),
      home: Login(ip: ip),
      routes: {
        '/send': (context) => DataSend(title: 'Data send', ip: ip),
        '/faceRecognition': (context) => FaceRecognition(ip: ip),

      },
    );
  }
}

class Login extends StatefulWidget {
   Login({Key? key, required this.ip}) : super(key: key);

  final String ip;
  String message = "";


   @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final myUsernameTextController = TextEditingController();
  final myPasswordTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }



  @override
  void dispose() {
    super.dispose();
    myUsernameTextController.dispose();
    myPasswordTextController.dispose();
  }

  serverRequest(String username, String password) async{
    print("U: $username, P: $password");

    Map<String, dynamic> data = {
      'username': username,
      'password': password,
    };

    print("Sending to:${widget.ip}");
    // Convert capture data to JSON
    String jsonData = jsonEncode(data);

    print("Sending ${data.toString()} to:${widget.ip}");


    // Navigator.pushNamed(context, '/send');

    try {
      // Send a POST request to the API endpoint
      // var http;
      final response = await http.post(
        Uri.parse('${widget.ip}:3001/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonData,
      );

      if (response.statusCode == 200) {
        // Capture data successfully sent
        print('Capture data sent successfully');
        var recived = jsonDecode(response.body);
        var id = recived['_id'];
        print(id);

        Navigator.pushNamed(context, '/faceRecognition', arguments: id);

      }else if(response.statusCode == 401){
        print('Invalid credentials: ${response.statusCode}');
        setState(() {
          widget.message = "Wrong username or password";
        });
      }else {
        // Handle error if capture data sending failed
        print('Failed to send capture data: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any exceptions or network errors
      print('Error sending capture data: $error');
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: myUsernameTextController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'User Name',
                    hintText: 'username'
                ),
              ),
            ),
             Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: myPasswordTextController,
                obscureText: true,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter your secure password'
                ),
              ),
            ),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: () {
                  serverRequest(myUsernameTextController.text, myPasswordTextController.text);
                },
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
            Text(
              widget.message
            )
          ],
        ),
      ),
    );
  }
}



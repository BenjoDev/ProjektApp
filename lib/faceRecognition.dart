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

class FaceRecognition extends StatefulWidget {

  FaceRecognition({Key? key, required this.ip}) : super(key: key);
  final String ip;

@override
  _FaceRecognitionState createState() => _FaceRecognitionState();
}

class _FaceRecognitionState extends State<FaceRecognition> {

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
      // Navigator.pushNamed(context, '/send');

      // Handle the captured image path, e.g., display it in an ImageView
      print('Image Path: ${imagePath.path}');
    }
  }

  uploadImage() async{
    final id = ModalRoute.of(context)!.settings.arguments;
    print("recived id: $id");


    final response0 = await http.post(Uri.parse('${widget.ip}:5000/name'), body: json.encode({'name' : '0'})); // 0 = Benjamin, 1 = Žan

    final request = http.MultipartRequest("POST", Uri.parse('${widget.ip}:5000/upload'));
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
      print("thisMessage:$message");
      if(message != "0"){
        Navigator.pushNamed(context, '/send');
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

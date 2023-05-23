
import 'dart:convert';

Future<void> sendCaptureData(  Map<String, dynamic> _readData) async {
  // Define the capture data to send

  print("Sending!!!");
  // Convert capture data to JSON
  String jsonData = jsonEncode(_readData);
  // String jsonData = jsonEncode(_readData);

  try {
    // Send a POST request to the API endpoint
    var http;
    final response = await http.post(
      Uri.parse('http://164.8.39.81:3001/phoneData'),
      // Uri.parse('http://10.0.2.2:3001/phoneData'),
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
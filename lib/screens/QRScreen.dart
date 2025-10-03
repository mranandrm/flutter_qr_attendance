import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/Constants.dart';

class QRScreen extends StatefulWidget {
  final String title;
  const QRScreen({super.key, required this.title,});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  String identifier = "";
  String qrCode = "";

  // Function to call the Laravel API and get the QR code
  Future<void> fetchQRCode() async {
    final response = await http.post(
      // Uri.parse('http://192.168.1.73:8000/api/attendance/generate-qrcode'),
      Uri.parse(Constants.BASE_URL + Constants.GENRATE_QR_ROUTE),
      headers: {
        'Accept': 'application/json',
        // 'Authorization': 'Bearer bywLUh9RRYmjXdYYF4qzyqjPy2D1mBsfmEnqMRxnb61dcd8a', // Include your authentication token
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      print(data);

      setState(() {
        identifier = data['identifier'];
        qrCode = data['qrCode'];
      });
    } else {
      throw Exception('Failed to load QR code');
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch the QR code when the screen is loaded
    fetchQRCode();
  }

  // Function to reload QR code data
  void reloadQRCode() {
    fetchQRCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance QR Code'),
        actions: [
          // Add a reload action button to the app bar
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: reloadQRCode,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the QR code using the identifier received from the API
            Image.memory(base64Decode(qrCode)),
            SizedBox(height: 20.0),
            Text(
              'Scan this QR code to mark attendance',
              style: TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            Text(
              'Identifier: $identifier',
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
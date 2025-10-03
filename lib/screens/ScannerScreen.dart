import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';

import '../services/Auth.dart';
import 'AttendanceAlreadyMarkedScreen.dart';
import 'AttendanceMarkedSuccessfullyScreen.dart';

class ScannerScreen extends StatefulWidget {
  final String title;

  const ScannerScreen({Key? key, required this.title}) : super(key: key);

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  String barcode = 'No data';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: TabBar(
            tabs: const [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.qr_code), text: 'QR Scanner'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Home Tab
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Home Tab Content'),
                ],
              ),
            ),
            // QR Scanner Tab
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Scanned Data: $barcode'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => startScan(),
                    child: const Text('Start QR scan'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> startScan() async {
    String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
      '#2ecc71',
      'Cancel',
      true,
      ScanMode.QR,
    );

    if (!mounted || barcodeScanResult == "-1") return; // "-1" = cancelled

    setState(() {
      barcode = barcodeScanResult;
    });

    print("QR Code $barcodeScanResult");

    List<String> explodedList = barcodeScanResult.split("&");

    Map<String, dynamic> qrData = {
      "event_id": explodedList[0],
      "event_name": explodedList[1],
      "event_date": explodedList[2],
      "event_location": explodedList[3],
    };

    Map<String, dynamic> requestData = {
      "qr_data": qrData,
    };

    // ✅ Await markAttendance
    await Provider.of<Auth>(context, listen: false)
        .markAttendance(attendance: requestData);

    // ✅ Now safely read the provider flags
    final authProvider = Provider.of<Auth>(context, listen: false);
    bool success = authProvider.markAttendanceSuccess;
    // String? attendanceTime = authProvider.attendanceTime;

    if (success) {
      // Show SnackBar for success
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Attendance marked at $attendanceTime")),
      // );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const AttendanceMarkedSuccessfullyScreen(title: 'Success'),
        ),
      );

      // Reset the flag
      authProvider.resetMarkAttendanceSuccess();
    } else {
      // Show SnackBar for already marked
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Attendance already marked")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const AttendanceAlreadyMarkedScreen(title: 'Warning'),
        ),
      );
    }
  }
}
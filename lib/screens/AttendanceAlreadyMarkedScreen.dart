import 'package:flutter/material.dart';

class AttendanceAlreadyMarkedScreen extends StatefulWidget {
  final String title;

  const AttendanceAlreadyMarkedScreen({Key? key, required this.title}) : super(key: key);

  @override
  _AttendanceAlreadyMarkedScreenState createState() => _AttendanceAlreadyMarkedScreenState();
}

class _AttendanceAlreadyMarkedScreenState extends State<AttendanceAlreadyMarkedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              color: Colors.orange,
              size: 100,
            ),
            SizedBox(height: 20),
            Text(
              'Attendance already marked!',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
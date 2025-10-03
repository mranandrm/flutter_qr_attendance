import 'package:flutter/material.dart';

class AttendanceMarkedSuccessfullyScreen extends StatefulWidget {
  final String title;

  const AttendanceMarkedSuccessfullyScreen({Key? key, required this.title}) : super(key: key);

  @override
  _AttendanceMarkedSuccessfullyScreenState createState() => _AttendanceMarkedSuccessfullyScreenState();
}

class _AttendanceMarkedSuccessfullyScreenState extends State<AttendanceMarkedSuccessfullyScreen> {

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
              Icons.check_circle,
              color: Colors.green,
              size: 100,
            ),
            SizedBox(height: 20),
            Text(
              'Attendance marked successfully!',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_qr_attendance/screens/HomeScreen.dart';
import 'package:flutter_qr_attendance/services/Auth.dart';
import 'package:provider/provider.dart';



void main() {
  // runApp(MyApp());

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => Auth())
        ],
        child: MyApp(),
      )
  );

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(title: 'Time Trace',),
    );
  }
}
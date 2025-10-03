import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart' as Dio;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/User.dart';
import '../utils/Constants.dart';
import 'dio.dart';

class Auth extends ChangeNotifier {

  bool _isLoggedIn = false;

  User? _user;

  String? _token;

  bool get authenticated => _isLoggedIn;

  User? get user => _user;

  // Flutter Secure Storage
  // Create storage
  final storage = new FlutterSecureStorage();

  void login({required Map creds}) async {
    print(creds);

    try {

      Dio.Response response = await dio().post(Constants.LOGIN_ROUTE, data: creds);

      print(response.data);

      String token = response.data.toString();

      this.tryToken(token: token);

      _isLoggedIn = true;
      notifyListeners();

    } catch (e) {
      if (e is DioError) {
        // Handle DioError
        print('DioError: $e');
        if (e.response != null) {
          print('Response data: ${e.response?.data}');
          print('Response status: ${e.response?.statusCode}');
        }
      } else {
        // Handle other errors
        print('Login Error: $e ${Constants.BASE_URL} ${Constants.LOGIN_ROUTE}');
      }
      // Handle the error appropriately (show a message, etc.)
    }
  }

  void tryToken({required String token}) async {

    if(token == null) {
      return;
    }
    else {

      try {

        Dio.Response response = await dio().get(
            '/user',
            options: Dio.Options(headers: {'Authorization' : 'Bearer $token'})
        );

        _isLoggedIn = true;

        this._user = User.fromJson(response.data);

        this._token = token;

        this.storeToken(token: token);

        notifyListeners();

        print(this._user);


      } catch (e) {

      }


    }

  }

  void storeToken({required String token}) async {

    this.storage.write(key: 'token', value: token);

  }

  void logout() async {

    dynamic token = await this.storage.read(key: 'token');

    try {
      print('logout started');

      Dio.Response response = await dio().get(
          Constants.LOGOUT_ROUTE,
          options: Dio.Options(headers: {'Authorization' : 'Bearer $token'})
      );

      print(response.data);

      cleanUp();
      notifyListeners();

      print('logout ended');

    }
    catch (e) {
      print(e);
    }

    notifyListeners();
  }

  void cleanUp() async {

    this._user = null;
    this._isLoggedIn = false;
    this._token = null;

    await storage.delete(key: 'token');

  }

  bool _markAttendanceSuccess = false;

  bool get markAttendanceSuccess => _markAttendanceSuccess;

  int _attendanceStatusCode = 200;

  int get attendanceStatusCode => _attendanceStatusCode;

  Future<void> markAttendance({required Map attendance}) async {
    try {
      // Get the user's token
      String? token = await storage.read(key: 'token');

      if (token == null) {
        print('User not authenticated');
        return;
      }

      String eventId = attendance['qr_data']['event_id'].toString();

      print(Constants.MARK_ATTENDANCE + eventId);

      Dio.Response response = await dio().post(
        Constants.MARK_ATTENDANCE + eventId,
        data: attendance,
        options: Dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data;

      print("data ${data}" ); // debug response

      if (response.statusCode == 201) {
        // ✅ Attendance marked
        print('${data['message']} at ${data['attendance_time']}');

        _markAttendanceSuccess = true;
        _attendanceStatusCode = response.statusCode!;

        // Optionally store attendance_time for UI
        // _attendanceTime = data['attendance_time'];

        notifyListeners();
      } else if (response.statusCode == 200) {
        // ✅ Already marked
        print(data['message']);

        _markAttendanceSuccess = false;
        _attendanceStatusCode = response.statusCode!;
        notifyListeners();
      } else {
        // ❌ Unexpected case
        print('Failed: ${response.statusCode} ${data}');
        _markAttendanceSuccess = false;
        notifyListeners();
      }
    } catch (e) {
      print('Error during Attendance: $e');
      if (e is DioError) {
        print('DioError: ${e.response?.statusCode} ${e.response?.data}');
      }
      _markAttendanceSuccess = false;
      notifyListeners();
    }
  }

  void resetMarkAttendanceSuccess() {
    _markAttendanceSuccess = false;
  }


}
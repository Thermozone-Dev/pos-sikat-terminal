import 'dart:convert';

import 'package:bir_pos/models/user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../login.dart'; // adjust import path to your actual Login screen
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For dev env variables
import 'package:device_info_plus/device_info_plus.dart'; // For Device Info

class AuthService {
  static Future<void> signOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final deviceInfo = DeviceInfoPlugin();
    final windowsDeviceInfo = await deviceInfo.windowsInfo;

    if (token == null) {
      print('No token found');
      return;
    }

    try {
      final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
      final String apiUri = dotenv.env['POS_API_URL'] ?? "";
      final deviceName = windowsDeviceInfo.computerName;
      final url = Uri.parse('$apiUri/api/auth/logout');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Pos-Secret-key': apiSecret,
        },
        body: jsonEncode({
          'device_name': deviceName,
          // '': '',
        }),
      );

      if (response.statusCode == 204) {
        print('Logout successful');
      } else {
        print('Logout failed: ${response.body}');
      }

      await prefs.remove('token');

      // Navigate to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Login()),
        (route) => false,
      );
    } catch (e) {
      print('Logout error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed')));
    }
  }

  static Future<User> getUser(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      if (token == null) {
        print('No token found');
      }

      final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
      final String apiUri = dotenv.env['POS_API_URL'] ?? "";
      final url = Uri.parse('$apiUri/api/auth/user');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Pos-Secret-key': apiSecret,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        print('User Data Call failed: ${response.body}');
        throw Exception('User Data Call failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('User Data error: $e');
    }
  }

  static Future<bool> isManager(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      if (token == null) {
        print('No token found');
      }

      final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
      final String apiUri = dotenv.env['POS_API_URL'] ?? "";
      final url = Uri.parse('$apiUri/api/auth/manager');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Pos-Secret-key': apiSecret,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['is_manager'];
      } else {
        print('User Data Call failed: ${response.body}');
        throw Exception('User Data Call failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('User Data error: $e');
    }
  }
}

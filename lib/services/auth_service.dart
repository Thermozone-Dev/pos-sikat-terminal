import 'dart:convert';

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
      final deviceName = windowsDeviceInfo.computerName;
      final apiSecret = dotenv.env['POS_API_SECRET'];
      final apiUri = dotenv.env['POS_API_URL'];
      final url = Uri.parse('$apiUri/api/auth/logout');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'secret_key': apiSecret,
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
}

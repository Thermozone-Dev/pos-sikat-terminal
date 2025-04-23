import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../login.dart'; // adjust import path to your actual Login screen

class AuthService {
  static Future<void> signOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('No token found');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://bir-pos.test/api/auth/logout?device_name=test'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
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

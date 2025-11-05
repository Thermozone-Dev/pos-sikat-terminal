import 'package:bir_pos/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For dev env variables

late SharedPreferences prefs;

void main() async {
  await dotenv.load(fileName: ".env"); // Load .env file
  prefs = await SharedPreferences.getInstance();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Login());
  }
}

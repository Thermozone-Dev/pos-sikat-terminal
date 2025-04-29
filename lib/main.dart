import 'package:bir_pos/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For dev env variables

void main() async {
  await dotenv.load(fileName: ".env"); // Load .env file
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Login());
  }
}

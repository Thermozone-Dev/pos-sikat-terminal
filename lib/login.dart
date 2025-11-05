import 'package:bir_pos/models/user.dart';
import 'package:flutter/material.dart';
import 'package:bir_pos/terminal.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For jsonEncode & jsonDecode
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For dev env variables
import 'package:device_info_plus/device_info_plus.dart'; // For Device Info
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Secure Storage

class Login extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final deviceInfo = DeviceInfoPlugin();
  final secStorage = FlutterSecureStorage();

  bool _isLoading = false;

  Future<void> _clearSession() async {
    final keysToClear = ['transaction_data'];
    await Future.wait(keysToClear.map((key) => secStorage.delete(key: key)));
  }

  Future<void> _login() async {
    final prefs = await SharedPreferences.getInstance();
    final windowsDeviceInfo = await deviceInfo.windowsInfo;

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final deviceName = windowsDeviceInfo.computerName;
      final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
      final String apiUri = dotenv.env['POS_API_URL'] ?? "";
      final url = Uri.parse('$apiUri/api/auth/login');

      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Pos-Secret-key': apiSecret,
          },
          body: jsonEncode({
            'email': email,
            'password': password,
            'device_name': deviceName,
          }),
        );

        setState(() => _isLoading = false);

        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          final token = data['token'];
          final userName = data['name'];
          final terminalId = data['terminal_id'];

          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Login successful!')));
          }

          await prefs.setString('token', token);
          await prefs.setString('user_name', userName);
          await prefs.setString('terminal_id', terminalId.toString());

          _clearSession();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Terminal(token: token)),
          );
        } else {
          final errorData = jsonDecode(response.body);
          final message = errorData['message'] ?? 'Login failed';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      } catch (e) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Container(
              width: 450,
              padding: EdgeInsets.all(50),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/img/logo.png', height: 150),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (value) => _login(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[500],
                            padding: EdgeInsets.symmetric(
                              horizontal: 60.0,
                              vertical: 16.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Login",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 16,
            right: 16,
            child: Text(
              "POS-Sikat v1.0",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}

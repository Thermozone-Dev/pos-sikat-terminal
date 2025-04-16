import 'package:flutter/material.dart';
import 'package:bir_pos/terminal.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For jsonEncode & jsonDecode

class Login extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Add this for loading state (optional)
  bool _isLoading = false;

  // 🧠 LOGIN FUNCTION: Handles API call
  Future<void> _login() async {
    final prefs = await SharedPreferences.getInstance();
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Prepare the GET request with query parameters
      final deviceName = 'test';
      final email = Uri.encodeComponent(_emailController.text.trim());
      final password = Uri.encodeComponent(_passwordController.text.trim());
      final url = Uri.parse(
        'http://bir-pos.test/api/auth/login?email=$email&password=$password&device_name=$deviceName',
      );

      try {
        final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            // 'Authorization': 'Bearer $token',
          },
        );

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final token = data['token']; // adjust based on actual API response

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Login successful!')));

          print("Token: $token");

          await prefs.setString('token', token);

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
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
                Image(image: AssetImage('assets/img/banner-light.png')),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter email';
                    if (!value.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter password';
                    if (value.length < 6)
                      return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                SizedBox(height: 30),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _login,
                      child: Text(
                        "Login",
                        style: TextStyle(color: Colors.white),
                      ),
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
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/package.dart';
import 'dart:convert';

class PackageService {
  static Future<List<Package>> getPackages() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('http://bir-pos.test/api/v1/itemPackages');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Package.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load packages');
    }
  }
}

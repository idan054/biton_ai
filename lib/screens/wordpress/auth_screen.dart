import 'dart:convert';
import 'package:biton_ai/common/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


//! this screen For DEBUG Usage
//> Because the official website will pass the JWT

//{
//     "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL3dvcmRwcmVzcy02NjU4NjYtMzQ2MjgwMi5jbG91ZHdheXNhcHBzLmNvbSIsImlhdCI6MTY4MzU0Nzk5MywibmJmIjoxNjgzNTQ3OTkzLCJleHAiOjE2ODQxNTI3OTMsImRhdGEiOnsidXNlciI6eyJpZCI6IjEifX19.n96I309puSOOS1kvX2MOOuUFZ2PsbykzFeab5koj72Y",
//     "user_email": "eyal10bit@gmail.com",
//     "user_nicename": "eyalbit",
//     "user_display_name": "Eyalbit"
// }

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    final response = await http.post(
      Uri.parse('$baseUrl/wp-json/jwt-auth/v1/token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': _usernameController.text.trim(),
        'password': _passwordController.text.trim(),
      }),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final token = json['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      Navigator.of(context).pop();
    } else {
      final json = jsonDecode(response.body);
      setState(() {
        _error = json['message'];
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(hintText: 'Username'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(hintText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading ? const CircularProgressIndicator() : Text('Login'),
            ),
            if (_error != null) SizedBox(height: 16),
            if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}



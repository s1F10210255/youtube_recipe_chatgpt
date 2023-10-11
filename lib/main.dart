import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Redirect Test'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: _checkRedirect,
            child: Text('Check Redirect'),
          ),
        ),
      ),
    );
  }

  void _checkRedirect() async {
    final response = await http.get(Uri.parse('http://localhost:5000'));
    if (response.statusCode == 302) {  // 302 is the HTTP status code for redirection
      print('Redirected to: ${response.headers['location']}');
    } else {
      print('No redirect');
    }
  }
}

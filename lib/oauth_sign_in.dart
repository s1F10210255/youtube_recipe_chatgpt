import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';

class Auth {
  static const String clientId = '359218122786-l8gpar1s81v4c7c1hk95cub1p3cqkv2t.apps.googleusercontent.com';
  static const String redirectUri = 'https://youtube-api-401500.firebaseapp.com/_/auth/handler';

  static Future<String> signInWithOAuth(BuildContext context) async {
    final result = await FlutterWebAuth.authenticate(
      url: "https://accounts.google.com/o/oauth2/auth?client_id=$clientId&redirect_uri=$redirectUri&response_type=code&scope=email%20profile",
      callbackUrlScheme: "com.yourapp",
    );

    final token = Uri.parse(result).queryParameters['code'];
    return token ?? '';
  }
}

class OAuthSignInPage extends StatefulWidget {
  @override
  _OAuthSignInPageState createState() => _OAuthSignInPageState();
}

class _OAuthSignInPageState extends State<OAuthSignInPage> {
  String _accessToken = '';

  Future<void> _signInWithOAuth() async {
    final token = await Auth.signInWithOAuth(context);
    setState(() {
      _accessToken = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OAuth Sign In'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _accessToken.isNotEmpty ? 'Access Token: $_accessToken' : 'Not Signed In',
            ),
            ElevatedButton(
              onPressed: _signInWithOAuth,
              child: Text('Sign In with OAuth'),
            ),
          ],
        ),
      ),
    );
  }
}

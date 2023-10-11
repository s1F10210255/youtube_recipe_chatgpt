import 'package:oauth2/oauth2.dart' as oauth2;
import 'dart:io';

class Auth {
  static Future<oauth2.Client> authenticate() async {
    final authorizationEndpoint = Uri.parse("https://accounts.google.com/o/oauth2/auth");
    final tokenEndpoint = Uri.parse("https://oauth2.googleapis.com/token");

    final identifier = "359218122786-l8gpar1s81v4c7c1hk95cub1p3cqkv2t.apps.googleusercontent.com";
    final secret = "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";
    final redirectUrl = Uri.parse("http://localhost:5000");

    final oauth2.AuthorizationCodeGrant grant = oauth2.AuthorizationCodeGrant(
      identifier,
      authorizationEndpoint,
      tokenEndpoint,
      secret: secret,
    );

    // This will redirect the user to the authorization URL
    final authorizationUrl = grant.getAuthorizationUrl(redirectUrl);

    // Wait for the user to enter the authorization code
    print("Please enter the authorization code:");
    final code = stdin.readLineSync();

    // Request new credentials using the authorization code
    return await grant.handleAuthorizationResponse({'code': code!});
  }
}
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class GetServerKey {
  Future<String> getServiceKeyToken() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
      // 'https://www.googleapis.com/auth/spreadsheets'
    ];
    final responeFile = await rootBundle.loadString(
        'assets/chatapp-c4dc9-firebase-adminsdk-fbsvc-195a7b7a4f.json');
    final Map<String, dynamic> readServiceAccountCredentials =
        json.decode(responeFile);
    final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(
          readServiceAccountCredentials,
        ),
        scopes);
    final accessServerkey = client.credentials.accessToken.data;
    return accessServerkey;
  }
}

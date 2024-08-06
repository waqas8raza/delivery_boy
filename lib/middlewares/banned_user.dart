import 'dart:convert';
import 'package:active_flutter_delivery_app/helpers/auth_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'middleware.dart';

class BannedUser extends Middleware<bool, http.Response> {
  @override
  bool next(http.Response response) {
   /* var jsonData = jsonDecode(response.body);
    if (jsonData.runtimeType != List &&
        jsonData.containsKey("result") &&
        !jsonData['result']) {
      if (jsonData.containsKey("status") && jsonData['status'] == "banned") {
        AuthHelper().clearUserData();
        Navigator.pushAndRemoveUntil(OneContext().context!,
            MaterialPageRoute(builder: (context) => Main()), (route) => false);
        return false;
      }
    }*/
    return true;
  }
}

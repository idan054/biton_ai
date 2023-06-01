import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:rich_console/rich_console.dart';

String? handleExceptions(Response? resp, {Exception? err}) {
  String? message;
  if (resp != null) {
    final json = jsonDecode(resp.body);
    message = json['message'];
    var code = json['code'];
    var status = json['data']?['status'] ?? '';
  } else {
    message = err.toString();
  }

  if (message == 'Expired token') return 'Oops! Please re-login your account';

  if (message.toString().contains('that username already exists!')) {
    return 'Please login, Email exists';
  }

  if (message.toString().contains('password you entered')) {
    return 'Oops! password is incorrect';
  }

  if (message.toString().contains('Unknown email address')) {
    // return "Oops! Profile doesn't exist";
    return "Email not found, please signup";
  }

  if (message.toString().contains('invalid-phone-number')) {
    return "Oops! Please use a valid phone";
  }

  return message;
}

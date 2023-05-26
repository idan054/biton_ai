import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:rich_console/rich_console.dart';

String? handleExceptions(Response resp) {
  final json = jsonDecode(resp.body);

  var code = json['code'];
  var message = json['message'];
  var status = json['data']?['status'] ?? '';

  if (message == 'Expired token') return 'Oops! Please re-login your account';

  if (message.toString().contains('that username already exists!')) {
    return 'Please login, Profile email exists';
  }

  if (message.toString().contains('password you entered')) {
    return 'Oops! password is incorrect';
  }

  return message;
}

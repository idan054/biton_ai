import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:rich_console/rich_console.dart';

String? handleExceptions(Response resp){
  final json = jsonDecode(resp.body);
  var code = json['code'];
  var message = json['message'];
  var status = json['data']['status'];
  if(message == 'Expired token') return 'Oops! Please re-login your profile';
  return null;
}
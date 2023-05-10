import 'dart:convert';
import 'package:biton_ai/common/constants.dart';
import '../../screens/wordpress/auth_screen.dart' as click;
import 'package:biton_ai/common/models/post/woo_post_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../screens/wordpress/woo_posts_screen.dart';
import '../models/category/woo_category_model.dart';
import '../models/user/woo_user_model.dart';

class WooApi {
  static Future<List<WooCategoryModel>> getCategories() async {
    print('START: WooApi.getCategories()');

    const url = '$baseUrl/wp/v2/categories?parent=$appCategoryId';
    final response = await http.get(Uri.parse(url));
    print('WooApi.getCategories() statusCode: ${response.statusCode}');
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      var categories = jsonList.map((json) => WooCategoryModel.fromJson(json)).toList();
      return categories;
    } else {
      throw Exception('Failed to get categories');
    }
  }

  static Future<List<WooPostModel>> getPosts({
    String? userId,
  }) async {
    print('START: WooApi.getPosts()');

    var url = '$baseUrl/wp/v2/posts';
    if (userId != null) url += '?author=$userId';
    final response = await http.get(Uri.parse(url));
    print('WooApi.getPosts() statusCode: ${response.statusCode}');
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      var posts = jsonList.map((json) => WooPostModel.fromJson(json)).toList();
      return posts;
    } else {
      throw Exception('Failed to create post');
    }
  }

  static Future<WooPostModel> createPost(WooPostModel post, {int? updatePostById}) async {
    print('START: WooApi.createPost()');
    var url = '$baseUrl/wp/v2/posts';
    if (updatePostById != null) url += '/$updatePostById';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $debugJwt',
      },
      body: jsonEncode({
        'title': post.title,
        'content': post.content,
        'author': post.author,
        'categories': post.categories,
        'status': 'publish',
      }),
    );

    print('WooApi.createPost() statusCode: ${response.statusCode}');
    if (updatePostById != null) print('UPDATE MODE For post ID: $updatePostById');

      if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return WooPostModel.fromJson(json);
    } else {
      throw Exception('Failed to create post');
    }
  }

  ///~ GET JWT From [click.AuthScreen]
  static Future<WooUserModel> getUserByToken(String jwtToken) async {
    print('START: WooApi.getUserByToken()');

    final response = await http.get(
      Uri.parse('$baseUrl/wp/v2/users/me'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );
    print('WooApi.getUserByToken() statusCode: ${response.statusCode}');
    // print('response.body ${response.body}');
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return WooUserModel.fromJson(json);
      // setState(() {});
    } else {
      throw Exception('Failed to get user');
    }
  }

  static Future<WooUserModel> getUserById(String userId) async {
    print('START: WooApi.getUserById()');

    final response = await http.get(
      Uri.parse('$baseUrl/wp/v2/users/$userId'),
    );
    print('WooApi.getUserById() statusCode: ${response.statusCode}');
    // print('response.body ${response.body}');
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return WooUserModel.fromJson(json);
      // setState(() {});
    } else {
      throw Exception('Failed to get user');
    }
  }
}
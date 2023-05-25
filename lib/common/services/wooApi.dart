import 'dart:convert';
import 'package:biton_ai/common/constants.dart';
import 'package:biton_ai/common/services/color_printer.dart';
import 'package:biton_ai/common/services/handle_exceptions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../screens/wordpress/auth_screen.dart' as click;
import 'package:biton_ai/common/models/post/woo_post_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../screens/wordpress/woo_posts_screen.dart';
import '../models/category/woo_category_model.dart';
import '../models/user/woo_user_model.dart';

class WooApi {
  static String wooApiKey = dotenv.env['API_KEY']!;
  static String wooApiSecret = dotenv.env['API_SECRET']!;

  static Future<List<WooCategoryModel>> getCategories() async {
    printWhite('START: WooApi.getCategories()');

    const url = '$baseUrl/wp/v2/categories?parent=$appCategoryId';
    final response = await http.get(Uri.parse(url));
    print('WooApi.getCategories statusCode ${response.statusCode}');
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      var categories = jsonList.map((json) => WooCategoryModel.fromJson(json)).toList();
      return categories;
    } else {
      printRed('response.body ${response.body}');
      var exception = handleExceptions(response);
      throw Exception(exception ?? 'Failed to delete categories, please try again');
    }
  }

  static Future<List<WooPostModel>> getPosts({
    String? userId,
    required List<int> catIds,
    // required List<WooCategoryModel> categories,
  }) async {
    print('START: WooApi.getPosts()');

    var url = '$baseUrl/wp/v2/posts';
    url += '?per_page=100';
    if (userId != null) url += '&author=$userId,$textStoreUid';

    var catIdsEncoded =
        catIds.toString().replaceAll(' ', '').replaceAll('[', '').replaceAll(']', '');
    url += '&categories=$catIdsEncoded';

    final response = await http.get(Uri.parse(url));
    print('WooApi.getPosts() statusCode: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      var posts = jsonList.map((json) => WooPostModel.fromJson(json)).toList();
      for (var p in posts) print('${p.id} ${p.title} ${p.isDefault}');
      return posts;
    } else {
      printRed('response.body ${response.body}');
      var exception = handleExceptions(response);
      throw Exception(exception ?? 'Failed to get prompts, please try again');
    }
  }

  static Future<WooPostModel> updatePost(
    WooPostModel post, {
    int? postId,
    bool isSelected = false, // threeColumnDialog.dart
  }) async {
    print('START: WooApi.createPost()');
    bool updateMode = postId != null;
    var url = '$baseUrl/wp/v2/posts';
    if (updateMode) url += '/$postId';

    final headers = {
      'Content-Type': 'application/json',
      // 'Authorization': post.isDefault ? 'Bearer $adminJwt' : 'Bearer $appConfig_userJwt',
      'Authorization': 'Bearer $appConfig_userJwt',
    };

    print('updatePost() updateMode $updateMode');

    final body = jsonEncode({
      'title': post.title,
      'content': post.content,
      // 'author': post.isDefault ? textStoreUid : post.author,
      'categories': post.categories,
      'status': 'publish',
      'meta': {'isSelected': isSelected},
    });

    final response = updateMode
        ? await http.put(Uri.parse(url), headers: headers, body: body)
        : await http.post(Uri.parse(url), headers: headers, body: body);

    printGreen('WooApi.createPost() statusCode: ${response.statusCode}');
    if (response.statusCode == 201 || response.statusCode == 200) {
      final json = jsonDecode(response.body);
      var post = WooPostModel.fromJson(json);
      post.isSelected
          ? printLightBlue('[SELECT ${post.id}] ${post.title}')
          : printRed('[REMOVE ${post.id}] ${post.title}');
      return post;
    } else {
      printRed('response.body ${response.body}');
      var exception = handleExceptions(response);
      throw Exception(exception ?? 'Failed to create prompt, Please try again');
    }
  }

  static Future<void> deletePost(int postId) async {
    print('START: WooApi.deletePost()');
    var url = '$baseUrl/wp/v2/posts/$postId';

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $appConfig_userJwt',
      },
    );

    print('WooApi.deletePost() statusCode: ${response.statusCode}');
    if (response.statusCode != 204) {
      printRed('response.body ${response.body}');
      var exception = handleExceptions(response);
      throw Exception(exception ?? 'Failed to delete prompt, please try again');
    }
  }

  static Future userSignup({
    required String email,
    required String password,
  }) async {
    print('START: WooApi.createUser()');
    var url = '$baseUrl/wp/v2/users/';
    var username = email.split('@').first;

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $adminJwt',
    };
    var body = jsonEncode({
      'username': username,
      'email': email,
      'password': password,
      // author = Create / edit his posts
      // Editor = Create / edit Everyone posts
      'roles': ['editor']
    });

    final response = await http.post(Uri.parse(url), headers: headers, body: body);
    print('response.statusCode ${response.statusCode}');

    if (response.statusCode == 201) {
    } else {
      printRed('response.body ${response.body}');
      var exception = handleExceptions(response);
      throw Exception(exception ?? 'Failed to get user, please try again');
    }
  }

  static Future<String> userLogin({
    required String email,
    required String password,
  }) async {
    print('START: WooApi.userLogin()');
    var url = '$baseUrl/jwt-auth/v1/token/';

    var headers = {
      'Content-Type': 'application/json',
      // 'Authorization': 'Bearer $adminJwt',
    };

    var body = jsonEncode({
      'username': email,
      'password': password,
    });

    final response = await http.post(Uri.parse(url), headers: headers, body: body);
    print('response.statusCode ${response.statusCode}');

    if (response.statusCode == 200) {
      return json.decode(response.body)['token'];
    } else {
      printRed('response.body ${response.body}');
      var exception = handleExceptions(response);
      throw Exception(exception ?? 'Failed to get user, please try again');
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
      var user = WooUserModel.fromJson(json);
      print('user.toJson() ${user.toJson()}');

      return user;
      // setState(() {});
    } else {
      printRed('response.body ${response.body}');
      var exception = handleExceptions(response);
      throw Exception(exception ?? 'Failed to get user, please try again');
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

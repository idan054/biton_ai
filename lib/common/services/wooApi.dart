// ignore_for_file: curly_braces_in_flow_control_structures

import "dart:convert";
import "package:biton_ai/common/constants.dart";
import "package:biton_ai/common/services/color_printer.dart";
import "package:biton_ai/common/services/handle_exceptions.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:hive/hive.dart";
import "../../screens/wordpress/auth_screen.dart" as click;
import "package:biton_ai/common/models/post/woo_post_model.dart";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "../../screens/wordpress/woo_posts_screen.dart";
import "../models/category/woo_category_model.dart";
import "../models/user/woo_user_model.dart";

class WooApi {
  static String _wooApiKey = dotenv.env["API_KEY"]!;
  static String _wooApiSecret = dotenv.env["API_SECRET"]!;

  static Future<List<WooCategoryModel>> getCategories() async {
    printWhite("START: WooApi.getCategories()");

    const url = "$baseUrl/wp/v2/categories?parent=$appCategoryId";
    final response = await http.get(Uri.parse(url));
    print("WooApi.getCategories statusCode ${response.statusCode}");
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      var categories = jsonList.map((json) => WooCategoryModel.fromJson(json)).toList();
      return categories;
    } else {
      printRed("response.body ${response.body}");
      var exception = handleExceptions(response);
      throw Exception(exception ?? "Failed to delete categories, please try again");
    }
  }

  static Future<List<WooPostModel>> getPosts({
    String? userId,
    required List<int> catIds,
    // required List<WooCategoryModel> categories,
  }) async {
    print("START: WooApi.getPosts()");

    var url = "$baseUrl/wp/v2/posts";
    url += "?per_page=100";
    if (userId != null) url += "&author=$userId,$textStoreUid";

    var catIdsEncoded =
        catIds.toString().replaceAll(" ", "").replaceAll("[", "").replaceAll("]", "");
    url += "&categories=$catIdsEncoded";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      var posts = jsonList.map((json) => WooPostModel.fromJson(json)).toList();
      print(
          "WooApi.getPosts() statusCode: ${response.statusCode} [${posts.length} prompts found]");
      // for (var p in posts) print("${p.id} | ${p.title} | ${p.isDefault}");
      return posts;
    } else {
      printRed("response.body ${response.body}");
      var exception = handleExceptions(response);
      throw Exception(exception ?? "Failed to get prompts, please try again");
    }
  }

  static Future<WooPostModel> updatePost(
    WooUserModel currUser,
    WooPostModel post, {
    int? postId,
    bool isSelected = false, // threeColumnDialog.dart
  }) async {
    print("START: WooApi.updatePost()");

    bool updateMode = postId != null;
    if (post.author != currUser.id) {
      printYellow(
          "SKIP: Can't ${updateMode ? "update" : "create"} post ${post.id}: ${post.title}");
      return post;
    }

    // var url = "$baseUrl/wp/v2/posts";
    var url = "$baseUrl/wp/v2/posts";
    if (updateMode) url += "/$postId";

    final headers = {
      "Content-Type": "application/json",
      // "Authorization": post.isDefault ? "Bearer $adminJwt" : "Bearer $appConfig_userJwt",
      "Authorization": "Bearer $appConfig_userJwt",
    };

    // print("updatePost() updateMode $updateMode [${post.title}]");
    final body = jsonEncode({
      "title": post.title,
      "content": post.content,
      // "author": post.isDefault ? textStoreUid : post.author,
      "categories": post.categories,
      "status": "publish",
      "meta": {"isSelected": isSelected},
    });

    final response = updateMode
        ? await http.put(Uri.parse(url), headers: headers, body: body)
        : await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      printGreen("WooApi.createPost() statusCode: ${response.statusCode}");
      final json = jsonDecode(response.body);
      var post = WooPostModel.fromJson(json);
      post.isSelected
          ? printLightBlue("[SELECT ${post.id}] ${post.title}")
          : printRed("[REMOVE ${post.id}] ${post.title}");
      return post;
    } else {
      printRed("response.body ${response.body}");
      var exception = handleExceptions(response);
      throw Exception(exception ?? "Failed to create prompt, Please try again");
    }
  }

  static Future<void> deletePost(int postId) async {
    print("START: WooApi.deletePost() $postId");
    var url = "$baseUrl/wp/v2/posts/$postId";

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $appConfig_userJwt",
      },
    );

    if (response.statusCode == 200) {
      printGreen("WooApi.deletePost() statusCode: ${response.statusCode}");
    } else {
      printRed("response.body ${response.body}");
      var exception = handleExceptions(response);
      throw Exception(exception ?? "Failed to delete prompt, please try again");
    }
  }

  static Future<bool> checkPhoneExist(String phone) async {
    print("START: WooApi.checkPhoneExist()");

    final response =
        await http.get(Uri.parse("$baseUrl/ai-engine/v1/users-by-phone?phone=$phone"));

    print("WooApi.checkPhoneExist() statusCode: ${response.statusCode}");
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      print('jsonList $jsonList');
      return jsonList.isNotEmpty;
    } else {
      printRed("response.body ${response.body}");
      var exception = handleExceptions(response);
      throw Exception(exception ?? "Check if phone exist failed, please try again");
    }
  }

  static Future<bool> checkEmailExists(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/wp/v2/users?search=$email'));

    if (response.statusCode == 200) {
      print("WooApi.checkEmailExists() statusCode: ${response.statusCode}");

      final List<dynamic> users = json.decode(response.body);
      return users.isNotEmpty;
    } else {
      printRed("response.body ${response.body}");
      var exception = handleExceptions(response);
      throw Exception(exception ?? "Failed to check if user mail exist");
    }
  }

  static Future userSignup({
    required String email,
    required String password,
    required String phone,
  }) async {
    print("START: WooApi.userSignup()");
    var url = "$baseUrl/wp/v2/users/";
    var username =
        '${email.split("@").first}${UniqueKey().toString().replaceAll('[', '').replaceAll(']', '').replaceAll('#', '-')}';

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $adminJwt",
    };
    var body = jsonEncode({
      "username": username,
      "email": email,
      "password": password,
      // author = Create / edit his posts
      // Editor = Create / edit Everyone posts
      "roles": ["author"],
      "meta": {"phone": phone},
    });

    final response = await http.post(Uri.parse(url), headers: headers, body: body);
    print("response.statusCode ${response.statusCode}");

    if (response.statusCode == 201) {
    } else {
      printRed("response.body ${response.body}");
      var exception = handleExceptions(response);
      throw Exception(exception ?? "Failed to get user, please try again");
    }
  }

// AKA Generate App Token
  static Future<String> userLogin({
    required String email,
    required String password,
  }) async {
    print("START: WooApi.userLogin()");
    var url = "$baseUrl/jwt-auth/v1/token/";

    var headers = {
      "Content-Type": "application/json",
      // "Authorization": "Bearer $adminJwt",
    };

    var body = jsonEncode({
      "username": email,
      "password": password,
    });

    final response = await http.post(Uri.parse(url), headers: headers, body: body);
    print("response.statusCode ${response.statusCode}");

    if (response.statusCode == 200) {
      return json.decode(response.body)["token"];
    } else {
      printRed("response.body ${response.body}");
      var exception = handleExceptions(response);
      throw Exception(exception ?? "Failed to get user, please try again");
    }
  }

  static Future<WooUserModel> getUserByToken(String jwtToken) async {
    print("START: WooApi.getUserByToken()");

    final response = await http.get(
      Uri.parse("$baseUrl/wp/v2/users/me"),
      headers: {"Authorization": "Bearer $jwtToken"},
    );
    print("WooApi.getUserByToken() statusCode: ${response.statusCode}");
    // print("response.body ${response.body}");
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      var user = WooUserModel.fromJson(json);
      print("user.toJson() ${user.toJson()}");

      return user;
      // setState(() {});
    } else {
      printRed("response.body ${response.body}");
      var exception = handleExceptions(response);
      throw Exception(exception ?? "Failed to get user, please try again");
    }
  }

  static Future<WooUserModel> getUserById(String userId) async {
    print("START: WooApi.getUserById()");

    final response = await http.get(
      Uri.parse("$baseUrl/wp/v2/users/$userId"),
    );
    print("WooApi.getUserById() statusCode: ${response.statusCode}");
    // print("response.body ${response.body}");
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return WooUserModel.fromJson(json);
      // setState(() {});
    } else {
      throw Exception("Failed to get user");
    }
  }

  // Sign and redirect the App Website
  static Future<String> userWebToken() async {
    print("START: WooApi.webSignIn()");

    var box = await Hive.openBox("currUserBox");
    var userEmail = box.get("userEmail");
    var userPass = box.get("userPass");

    var headers = {
      "Content-Type": "application/json",
    };

    var body = jsonEncode({
      "username": "$userEmail",
      "password": "$userPass",
    });

    final response = await http.post(Uri.parse("$baseUrl/ai-engine/v1/web_token"),
        body: body, headers: headers);
    print("WooApi.getUserById() statusCode: ${response.statusCode}");
    print("response.body ${response.body}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json["jwt_token"];
    } else {
      throw Exception("Failed to JWT Web Token");
    }
  }
}

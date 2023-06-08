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

//~ For security reasons, use --web-port=2123 to use Wordpress API
class WooApi {
  // static String userMakerJwt = dotenv.env["USER_MAKER_JWT"]!;
  static String userMakerJwt = appConfig_userMaker_Jwt;

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
  }) async {
    print("START: WooApi.getPosts()");

    var url = "$baseUrl/wp/v2/posts";
    url += "?per_page=100";
    if (userId != null) url += "&author=$userId,$textStoreUid";

    var catIdsEncoded =
        catIds.toString().replaceAll(" ", "").replaceAll("[", "").replaceAll("]", "");
    url += "&categories=$catIdsEncoded";

    final headers = {
      "Content-Type": "application/json",
      // "Authorization": "Bearer $appConfig_userJwt",
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      var posts = jsonList.map((json) => WooPostModel.fromJson(json)).toList();
      print(
          "WooApi.getPosts() statusCode: ${response.statusCode} [${posts.length} prompts found]");
      // print("response.body ${response.body}");

      printWhite(r" ID | isAdmin | isDefault | title");
      for (var p in posts) print("${p.id} | ${p.isAdmin} | ${p.isDefault} | ${p.title}");
      return posts;
    } else {
      printRed("response.body ${response.body}");
      var exception = handleExceptions(response);
      throw Exception(exception ?? "Failed to get prompts, please try again");
    }
  }

  // Update / Create post
  static Future<WooPostModel> updatePost(
    WooUserModel currUser,
    WooPostModel post, {
    int? postId,
    bool isSelected = false, // threeColumnDialog.dart
  }) async {
    print("START: WooApi.updatePost()");

    bool updateMode = postId != null;
    if (post.author != currUser.id) {
      printYellow('post.author != currUser.id | ${post.author} != ${currUser.id}');
      printYellow(
          "SKIP: Can't ${updateMode ? "update" : "create"} post ${post.id}: ${post.title}");
      return post;
    }

    var url = "$baseUrl/wp/v2/posts";
    if (updateMode) url += "/$postId";

    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $appConfig_userJwt",
    };

    // print("updatePost() updateMode $updateMode [${post.title}]");
    final body = jsonEncode({
      "title": post.title,
      // "content": post.content,
      // "author": post.isAdmin ? textStoreUid : post.author,
      "categories": post.categories,
      "status": "publish",
      "acf": {
        "googleDesc": post.subContent,
        "prompt": post.content,
        "isSelected": isSelected
      },
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

  static Future<String?> checkPhoneExist(String phone) async {
    print("START: WooApi.checkPhoneExist()");

    final response =
        await http.get(Uri.parse("$baseUrl/ai-engine/v1/users-by-phone?phone=$phone"));

    print("WooApi.checkPhoneExist() statusCode: ${response.statusCode}");
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      print('jsonList $jsonList');
      return jsonList.isNotEmpty ? jsonList.first['email'] : null;
    } else {
      printRed("response.body ${response.body}");
      var exception = handleExceptions(response);
      throw Exception(exception ?? "Check if phone exist failed, please try again");
    }
  }

  static Future<WooUserModel?> userByEmail(String email) async {
    print('START: userByEmail() X');
    final url = '$baseUrl/wp/v2/users?search=$email';
    print('url ${url}');
    // print('userMakerJwt ${userMakerJwt}');
    final headers = {
      // 'Access-Control-Allow-Origin': '*',
      // 'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      "Content-Type": "application/json",
      "Authorization": "Bearer $userMakerJwt",
    };
    final response = await http.get(headers: headers, Uri.parse(url));

    print("WooApi.userByEmail() statusCode: ${response.statusCode}");
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      var users = jsonList.map((json) => WooUserModel.fromJson(json)).toList();
      print('users.length ${users.length}');
      if (users.isNotEmpty) print('users.first.toJson() ${users.first.toJson()}');

      return users.isEmpty ? null : users.first;
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
    required bool isGoogleAuth,
  }) async {
    print("START: WooApi.userSignup()");
    var url = "$baseUrl/wp/v2/users";
    var username =
        '${email.split("@").first}${UniqueKey().toString().replaceAll('[', '').replaceAll(']', '').replaceAll('#', '-')}';

    var headers = {
      // 'Access-Control-Allow-Origin': '*',
      // 'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      "Content-Type": "application/json",
      "Authorization": "Bearer $userMakerJwt",
    };
    var body = jsonEncode({
      "username": username,
      "email": email,
      "password": password,
      // author = Create / edit his posts
      // Editor = Create / edit Everyone posts
      "roles": ["author"],
      "meta": {"phone": phone}, // Needed for .checkPhoneExist()
      "acf": {
        "isGoogleAuth": isGoogleAuth,
        "phone": phone,
      },
    });

    final response = await http.post(Uri.parse(url), headers: headers, body: body);
    print("WooApi.userSignup() response.statusCode ${response.statusCode}");

    if (response.statusCode == 201) {
    } else {
      printRed("request body $body\n");
      printRed("response.body ${response.body}");
      var exception = handleExceptions(response);
      throw Exception(exception ?? "Something went wrong, Can't sign up");
    }
  }

// AKA Generate App Token
  static Future<String> userLogin({
    required String email,
    required String password,
  }) async {
    print("START: WooApi.userLogin()");

    // var url = "$baseUrl/jwt-auth/v1/token/";
    var url = "$baseUrl/simple-jwt-login/v1/auth";

    var headers = {
      "Content-Type": "application/json",
      // "X-WP-Nonce" : "a2318a6e32",
      // "Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2ODU3OTg4NTYsImVtYWlsIjoiZXlhbDEwYml0QGdtYWlsLmNvbSIsImlkIjoiMSIsInVzZXJuYW1lIjoiZXlhbDEwYml0QGdtYWlsLmNvbSJ9.g60z-DweicYuDj0DMVuRTn07dftT9L8NBoETlkiUfbU",
    };

    var body = jsonEncode({
      "email": email,
      // "username": email,
      "password": password,
    });

    final response = await http.post(Uri.parse(url), headers: headers, body: body);
    print("response.statusCode ${response.statusCode}");

    if (response.statusCode == 200) {
      // var token = json.decode(response.body)["token"];
      var token = json.decode(response.body)["data"]['jwt'];
      return token;
    } else {
      printRed("response.body ${response.body}");

      // var isEmailExist = json.decode(response.body)["data"]['message'] == 'Wrong user credentials.';
      //. ? '$email exist!\nLogin with Email & Password'
      // String? exception = (googleSignIn && isEmailExist) ? 'User exist!\nLogin with Email & Password' :

      String? exception = handleExceptions(response);
      // throw Exception(exception  ?? "Something wen wrong, User not found");
      throw Exception(exception ?? "signup or try different password");
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
      throw Exception(exception ?? "Something wen wrong, User not found");
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

  //! REPLACE WITH AUTO LOGIN
  static Future<String> userWebToken() async {
    print("START: WooApi.webSignIn()");

    var box = await Hive.openBox("currUserBox");
    var userEmail = box.get("userEmail");
    var userPass = box.get("userPass");

    var headers = {
      "Content-Type": "application/json",
      // "Authorization": "Bearer $userMakerJwt",
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

// ignore_for_file: use_build_context_synchronously, curly_braces_in_flow_control_structures, unused_local_variable, no_leading_underscores_for_local_identifiers

import 'dart:async';

import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:biton_ai/common/extensions/widget_ext.dart';
import 'package:biton_ai/common/extensions/num_ext.dart';
import 'package:biton_ai/common/services/color_printer.dart';
import 'package:biton_ai/common/services/wooApi.dart';
import 'package:biton_ai/common/themes/app_colors.dart';
import 'package:biton_ai/screens/resultsScreen.dart';
import 'package:biton_ai/widgets/resultsList.dart';
import 'package:curved_progress_bar/curved_progress_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../common/constants.dart';
import '../common/models/category/woo_category_model.dart';
import '../common/models/post/woo_post_model.dart';
import '../common/models/prompt/result_model.dart';
import '../common/services/gpt_service.dart';
import '../widgets/threeColumnDialog/actions.dart';
import '../widgets/threeColumnDialog/threeColumnDialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var searchController =
      TextEditingController(text: kDebugMode ? 'Nike Air Max 90' : null);
  List<WooCategoryModel> _categories = [];
  List<WooPostModel> _promptsList = [];
  List<WooPostModel> _inUsePrompts = [];

  @override
  void initState() {
    getPrompts();
    getCategories();
    super.initState();
  }

  void getPrompts() async {
    _promptsList = [];
    _inUsePrompts = [];
    _promptsList = await getAllUserPrompts();
    _inUsePrompts = setSelectedList(_promptsList);
    setState(() {});
  }

  void getCategories() async {
    _categories = [];
    _categories = await WooApi.getCategories();
    _categories = sortCategories(_categories);
    setState(() {});
  }

  bool _isLoading = false;

  // var loadingSeconds = 0;

  Timer? _timer; // 1 time run.
  String? loadingText;
  String? errorMessage;

  int loadingIndex = 0;

  @override
  Widget build(BuildContext context) {
    _isLoading = _isLoading && errorMessage == null;

    List loaderActivities = [
      'Get info about ${searchController.text}...',
      'Summery info about ${searchController.text}...',
      'Create 3 Google Titles...',
      'Create 3 Google Descriptions...',
      'Improve Google Titles & Descriptions SEO...',
      'Generate 3 Amazing Titles for your Product page...',
      'Generate 3 Short Descriptions (3-5 lines) for your Product page...',
      'Create a sales article for your Product page...',
    ];
    loadingText ??= loaderActivities.first;
    if (_isLoading && _timer == null) {
      _timer = Timer.periodic(const Duration(milliseconds: 3000), (timer) {
        // > Cycle loaderActivities list:
        // loadingIndex = (loadingIndex + 1) % loaderActivities.length;
        //> Stop at end loaderActivities list:
        if (loadingIndex < loaderActivities.length - 1) loadingIndex++;

        loadingText = loaderActivities[loadingIndex];
        setState(() {});
      });
    }
    var textFieldWidth = 800.0;
    return Scaffold(
      backgroundColor: AppColors.lightPrimaryBg,
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 300),

          textStoreAi.toText(fontSize: 50, bold: true),
          const SizedBox(height: 10),
          // 'Sell more by Ai Text for your store'.toText(fontSize: 20).px(25),
          // 'Fast | Create product | SEO'.toText(fontSize: 20).px(25),
          'Best Ai text maker for your store.'.toText(fontSize: 20).px(25),
          const SizedBox(height: 20),
          //~ Search TextField
          buildSearchBar(textFieldWidth, context),

          if (errorMessage != null)
            // 'This can take up to 15 seconds...'
            SizedBox(
              width: textFieldWidth,
              child: 'Something went wrong. Please try again'
                  .toText(color: AppColors.errRed, fontSize: 18)
                  .py(10)
                  .px(30)
                  .appearAll,
            ),

          if (_isLoading)
            // 'This can take up to 15 seconds...'
            SizedBox(
              width: textFieldWidth,
              child: '$loadingText'
                  .toText(color: AppColors.greyText, fontSize: 18)
                  .py(10)
                  .px(30)
                  .appearAll,
            ),
          const Spacer(),
          appVersion.toText(fontSize: 12).pad(10).centerLeft,
        ],
      ).center,
    );
  }

  SizedBox buildSearchBar(double textFieldWidth, BuildContext context) {
    return SizedBox(
      width: textFieldWidth,
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(99),
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            hoverColor: AppColors.greyLight.withOpacity(0.1),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(99),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.greyLight),
              borderRadius: BorderRadius.circular(99),
            ),
            hintText: 'Enter full product name',
            hintStyle: const TextStyle(color: Colors.grey),
            suffixIcon: Stack(
              // Use Stack to overlay prefixIcon and CircularProgressIndicator
              alignment: Alignment.center,
              children: [
                if (_isLoading)
                  CurvedCircularProgressIndicator(
                    strokeWidth: 4,
                    color: AppColors.primaryShiny,
                    backgroundColor: AppColors.greyLight,
                    animationDuration: 1500.milliseconds,
                  ).sizedBox(30, 30).px(10).py(5),
                if (!_isLoading)
                  // Icons.search_rounded.icon(color: Colors.blueAccent, size: 30)
                  'Create'
                      .toText(
                          color: _inUsePrompts.isEmpty
                              ? AppColors.primaryShiny.withOpacity(0.40)
                              : AppColors.primaryShiny,
                          medium: true,
                          fontSize: 14)
                      .px(20)
                      .py(15)
                      .onTap(
                          _inUsePrompts.isEmpty
                              ? null
                              : () async => _handleCreateProductButton(),
                          tapColor: AppColors.primaryShiny.withOpacity(0.15)),
              ],
            ),
            prefixIcon: Icons.tune
                .icon(
                    color: _categories.isEmpty || _promptsList.isEmpty
                        ? AppColors.greyText.withOpacity(0.30)
                        : AppColors.greyText,
                    size: 25)
                .px(20)
                .py(12)
                .onTap(_categories.isEmpty || _promptsList.isEmpty
                    ? null
                    : () async {
                        await showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return ThreeColumnDialog(
                              promptsList: _promptsList,
                              selectedPrompts: _inUsePrompts,
                              categories: _categories,
                            );
                          },
                        );
                        // To update lists from server
                        initState();
                      }),
          ),
        ),
      ).px(15),
    );
  }

  void _handleCreateProductButton() async {
    final String input = searchController.text;
    errorMessage = null;
    _isLoading = true;
    setState(() {});
    List<ResultModel> results = [];

    // Set prompt X3
    var gPrompt = _inUsePrompts.firstWhere((p) => p.category == ResultCategory.gResults);
    var content = gPrompt.content.replaceAll('[YOUR_INPUT]', input);
    var subContent = (gPrompt.subContent ?? '').replaceAll('[YOUR_INPUT]', input);
    var titlePrompts = <String>[];
    var gDescPrompts = <String>[];
    for (int i = 0; i < 3; i++) {
      titlePrompts.add(content);
      gDescPrompts.add(subContent);
    }

    results = await Gpt.getResults(
      type: ResultCategory.gResults,
      input: searchController.text,
      prompts: titlePrompts,
      gDescPrompts: gDescPrompts,
    ).catchError((err) {
      printRed('My ERROR: $err');
      print('err.runtimeType ${err.runtimeType}');
      errorMessage = err.toString();
      setState(() {});
    });
    _navigateToSearchResults(context, input, results);
  }

  void _navigateToSearchResults(
    BuildContext context,
    String input,
    List<ResultModel> results,
  ) {
    _isLoading = false;
    setState(() {});

    // Update user input in the prompt
    _inUsePrompts = _inUsePrompts
        .map((pBase) =>
            pBase.copyWith(content: pBase.content.replaceAll('[YOUR_INPUT]', input)))
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ResultsScreen(input, results, _inUsePrompts)),
    );
  }
}

List<ResultModel> setResultsFromGpt(Map<String, dynamic> resp, ResultCategory category) {
  List<ResultModel> items = [];

  // var usage = resp['usage'];
  var results =
      resp['choices'].map((item) => item['message']['content']).toList(growable: true);
  print('results $results');
  for (var result in [...results]) {
    var item = ResultModel(title: result, category: category);
    items.add(item);
  }
  return items;
}

Future<List<WooPostModel>> getAllUserPrompts() async {
  var postList =
      await WooApi.getPosts(userId: debugUid.toString(), catIds: promptsCategoryIds);
  postList = setDefaultPromptFirst(postList);
  return postList;
}

List<WooPostModel> setSelectedList(List<WooPostModel> _fullPromptList) {
  List<WooPostModel> _selectedPromptList = [];

  //1) Add user selected prompts
  for (var prompt in _fullPromptList) {
    if (prompt.isSelected) _selectedPromptList.add(prompt);
  }

  //2) Add default ONLY where needed
  for (var prompt in _fullPromptList) {
    if (_selectedPromptList.any((p) => p.category == prompt.category)) {
      // Do nothing, prompt.isSelected added for this category
    } else {
      if (prompt.isDefault) _selectedPromptList.add(prompt);
    }
  }
  return _selectedPromptList;
}

List<WooPostModel> setDefaultPromptFirst(List<WooPostModel> postList) {
  var _postList = postList;
  // Set the Default prompt on Top
  for (var post in [..._postList]) {
    if (post.isDefault) {
      _postList.remove(post);
      _postList.insert(0, post);
    }
  }
  return _postList;
}

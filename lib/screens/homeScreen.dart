// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:biton_ai/common/extensions/widget_ext.dart';
import 'package:biton_ai/common/extensions/num_ext.dart';
import 'package:biton_ai/common/services/color_printer.dart';
import 'package:biton_ai/common/services/wooApi.dart';
import 'package:biton_ai/common/themes/app_colors.dart';
import 'package:biton_ai/screens/resultsScreen.dart';
import 'package:biton_ai/widgets/resultsList.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../common/constants.dart';
import '../common/models/category/woo_category_model.dart';
import '../common/models/prompt/result_model.dart';
import '../common/services/gpt_service.dart';
import '../widgets/threeColumnDialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var searchController =
      TextEditingController(text: kDebugMode ? 'Nike Air Max 90' : null);
  List<WooCategoryModel> _categories = [];

  @override
  void initState() {
    getCategories();
    super.initState();
  }

  void getCategories() async {
    var categories = await WooApi.getCategories();
    _categories = categories;
    setState(() {});
  }

  bool _isLoading = false;
  bool _showLoadingText = false; // Only appear after 5 seconds
  // var loadingSeconds = 0;
  int loadingIndex = 0;

  Timer? _timer; // 1 time run.
  String? loadingText;
  String? errorMessage;

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
        //> Cycle loaderActivities list:
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

          betterSeller.toText(fontSize: 50, bold: true),
          const SizedBox(height: 30),
          //~ Search TextField
          SizedBox(
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
                        const CircularProgressIndicator(
                          strokeWidth: 7,
                          color: AppColors.primaryShiny,
                        ),
                      if (!_isLoading)
                        // Icons.search_rounded.icon(color: Colors.blueAccent, size: 30)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icons.inventory_2_rounded.icon(color: Colors.blueAccent, size: 25),
                            'Create'.toText(
                                color: AppColors.primaryShiny, medium: true, fontSize: 14)
                          ],
                        ).px(20).py(15).onTap(() async {
                          errorMessage = null;
                          _isLoading = true;
                          setState(() {});
                          List<ResultModel> results = [];
                          if (kDebugMode && appConfig_fastHomeScreen) {
                            results = const [
                              ResultModel(
                                  title: 'A A great google result title will appear here',
                                  desc:
                                      'A A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence.',
                                  category: ResultCategory.gResults),
                              ResultModel(
                                  title: 'B A great google result title will appear here',
                                  desc:
                                      'B A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence.',
                                  category: ResultCategory.gResults),
                              ResultModel(
                                  title: 'C A great google result title will appear here',
                                  desc:
                                      'C A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence.',
                                  category: ResultCategory.gResults),
                            ];
                          } else {
                            results = await Gpt.getResults(
                              type: ResultCategory.gResults,
                              input: searchController.text,
                              prompts: [
                                'Create a great google title for the product: ${searchController.text}',
                                'Create a great google title for the product: ${searchController.text}',
                                'Create a great google title for the product: ${searchController.text}',
                              ],
                              gDescPrompts: [
                                'Create a great google description about 2 lines for the product: ${searchController.text}',
                                'Create a great google description about 2 lines for the product: ${searchController.text}',
                                'Create a great google description about 2 lines for the product: ${searchController.text}',
                              ],
                            ).catchError((err) {
                              printRed('My ERROR: $err');
                              print('err.runtimeType ${err.runtimeType}');
                              errorMessage = err.toString();
                              setState(() {});
                            });
                          }
                          _navigateToSearchResults(
                              context, searchController.text, results);
                        }, tapColor: AppColors.primaryShiny.withOpacity(0.15)),
                    ],
                  ),
                  prefixIcon: Icons.tune
                      .icon(
                          color: _categories.isEmpty
                              ? AppColors.greyText.withOpacity(0.30)
                              : AppColors.greyText,
                          size: 25)
                      .px(20)
                      .py(12)
                      .onTap(_categories.isEmpty
                          ? null
                          : () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ThreeColumnDialog(_categories);
                                },
                              );
                            }),
                ),
              ),
            ).px(15),
          ),

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
        ],
      ).center,
    );
  }

  void _navigateToSearchResults(
      BuildContext context, String input, List<ResultModel> results) {
    _isLoading = false;
    setState(() {});
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResultsScreen(input, results)),
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

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
  bool _isLoading = false;
  bool _showLoadingText = false; // Only appear after 5 seconds

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

  var loadingSeconds = 0;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      Timer.periodic(const Duration(seconds: 1), (_) {
        loadingSeconds++;
        if (loadingSeconds == 3) _showLoadingText = true;
        setState(() {});
      });
    }

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
            width: 800,
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
                          _isLoading = true;
                          setState(() {});
                          final results = await Gpt.getResults(
                            type: ResultCategory.gResults,
                            input: searchController.text,
                            n: 3,
                          );
                          _navigateToSearchResults(context, searchController.text, results);
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

          if (_showLoadingText)
            'This can take up to 60 seconds...'
                .toText(color: AppColors.greyText, fontSize: 18)
                .py(10)
                .appearAll,
        ],
      ).center,
    );
  }

  void _navigateToSearchResults(BuildContext context, String input,  List<ResultModel> results) {
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

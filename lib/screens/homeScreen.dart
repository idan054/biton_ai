// ignore_for_file: use_build_context_synchronously

import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:biton_ai/common/extensions/widget_ext.dart';
import 'package:biton_ai/common/extensions/num_ext.dart';
import 'package:biton_ai/common/services/color_printer.dart';
import 'package:biton_ai/common/services/wooApi.dart';
import 'package:biton_ai/screens/resultsScreen.dart';
import 'package:biton_ai/widgets/resultsList.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../common/constants.dart';
import '../common/models/category/woo_category_model.dart';
import '../widgets/threeColumnDialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var searchController = TextEditingController(text: kDebugMode ? 'One dog name' : null);
  List<WooCategoryModel> _categories = [];
  bool _isLoading = false;

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 300),
          betterSeller.toText(fontSize: 50, bold: true),
          'Better product page by Ai'.toText(fontSize: 18, medium: true),

          const SizedBox(height: 10),
          SizedBox(
            width: 800,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(99),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[300]!),
                  borderRadius: BorderRadius.circular(99),
                ),
                hintText: 'Enter full product name',
                hintStyle: const TextStyle(color: Colors.grey),
                suffixIcon:
                Stack(
                  // Use Stack to overlay prefixIcon and CircularProgressIndicator
                  alignment: Alignment.center,
                  children: [
                    if (_isLoading) const CircularProgressIndicator(strokeWidth: 5),
                    if (!_isLoading)
                      // Icons.search_rounded.icon(color: Colors.blueAccent, size: 30)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icons.inventory_2_rounded.icon(color: Colors.blueAccent, size: 25),
                          'Create'.toText(
                              color: Colors.blueAccent, medium: true, fontSize: 14)
                        ],
                      ).px(20).py(15).onTap(() async {
                        _isLoading = true;
                        setState(() {});

                        var results = [];
                        // final resp = await callChatGPT(searchController.text, 3);
                        // var usage = resp['usage'];
                        // var results = resp['choices']
                        //     .map((item) => item['message']['content'])
                        //     .toList(growable: true);
                        // print('results $results');

                        _navigateToSearchResults(context, results);
                      }, tapColor: Colors.blue.shade100),
                  ],
                ),
                prefixIcon: Icons.tune
                    .icon(
                        color: _categories.isEmpty
                            ? Colors.blueGrey.withOpacity(0.30)
                            : Colors.blueGrey[600]!,
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
            ).px(15),
          )
        ],
      ).center,
    );
  }

  void _navigateToSearchResults(BuildContext context, List results) {
    _isLoading = false;
    setState(() {});
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ResultsScreen(
              )),
    );
  }
}

Future<Map<String, dynamic>> callChatGPT(String prompt, int n) async {
  printWhite('START: callChatGPT()');
  print('prompt: $prompt');

  const url = '$baseUrl/ai-engine/v1/call-chat-gpt';
  final headers = {'Content-Type': 'application/json'};
  final body = json.encode({'prompt': prompt, 'n': n});
  final response = await http.post(Uri.parse(url), headers: headers, body: body);
  print('response.statusCode ${response.statusCode}');
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    // print('jsonResponse ${jsonResponse}');
    return jsonResponse;
  } else {
    throw Exception('Failed to call API');
  }
}

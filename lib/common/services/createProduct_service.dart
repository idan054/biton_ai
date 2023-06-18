// ignore_for_file: use_build_context_synchronously, curly_braces_in_flow_control_structures, unused_local_variable, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:html';
import 'package:biton_ai/common/extensions/context_ext.dart';
import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:biton_ai/common/extensions/widget_ext.dart';
import 'package:biton_ai/common/extensions/num_ext.dart';
import 'package:biton_ai/common/models/user/woo_user_model.dart';
import 'package:biton_ai/common/services/color_printer.dart';
import 'package:biton_ai/common/services/wooApi.dart';
import 'package:biton_ai/common/themes/app_colors.dart';
import 'package:biton_ai/screens/resultsScreen.dart';
import 'package:biton_ai/widgets/resultsList.dart';
import 'package:curved_progress_bar/curved_progress_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import 'dart:convert';

import '../../screens/homeScreen.dart';
import '../constants.dart';
import '../models/post/woo_post_model.dart';
import '../models/prompt/result_model.dart';
import 'package:flutter/material.dart';
import 'package:google_cloud_translation/google_cloud_translation.dart' as cloud;
import 'gpt_service.dart';

Future<String?> createProductAction(
  BuildContext context,
  TextEditingController searchController,
) async {
  // final translator = GoogleTranslator(); // Free, but lower quality
  cloud.Translation translator =
      cloud.Translation(apiKey: 'AIzaSyDr_BqVcBI36gQDaQZMQQbUrpk_DGWN0xE');
  var _inUsePrompts = context.uniProvider.inUsePromptList;
  String input = searchController.text;
  String englishInput = input;
  String? sourceLangCode;
  String? errMessage = _checkWordsLimit(input);
  if (errMessage != null) throw Exception(errMessage);

  print('input.isEnglish ${input.isEnglish}');
  if (input.isEnglish) {
    printLightBlue('[PASS] Original input: $input');
  } else {
    // Prompt will be English
    final tValue = await translator.translate(text: input, to: 'en');
    englishInput = tValue.translatedText;
    sourceLangCode = tValue.detectedSourceLanguage;
    printYellow('Translated from $sourceLangCode to EN');
    print('Original: $input');
    print('Translated: $englishInput');
  }

  var results = await _getGptResult(
    context,
    englishInput,
    translateTo: sourceLangCode,
  ).catchSentryError(
    onError: (err, trace) {
      print('ERR: _getGptResult()');
      print('err ${err}');
      print('trace ${trace}');
    },
  );

  List<ResultModel> translatedResults = [];
  for (var res in results) {
    final cleanResult = res.title.replaceAll('"', '').replaceAll("'", "");
    final cleanSubResult = (res.desc ?? '').replaceAll('"', '').replaceAll("'", "");
    if (input.isEnglish) {
      printLightBlue('[PASS] Original result:\n$cleanResult\n');
    } else {
      final tValue =
          await translator.translate(text: cleanResult, to: sourceLangCode ?? 'en');
      cloud.TranslationModel? tSubValue;
      // Translation? tSubValue;
      if (res.desc != null) {
        tSubValue =
            await translator.translate(text: cleanSubResult, to: sourceLangCode ?? 'en');
      }
      translatedResults.add(
          res.copyWith(translatedTitle: tValue.translatedText, translatedDesc: tSubValue?.translatedText));
      printYellow('Translated from EN to ${tValue.detectedSourceLanguage}');
      print('Original: $cleanResult');
      print('Translated: ${tValue.translatedText}\n');
    }
  }

  if (translatedResults.isNotEmpty) results = translatedResults;

  _navigateToSearchResults(context, input, results);
  return errMessage;
}

String? _checkWordsLimit(String text) {
  String? errorMessage;
  var wordsCounter = text.trim().split(' ').length;
  if (wordsCounter <= 2) {
    // 3+ words
    errorMessage = '''For great results, we need details like:
- iPhone 14 Pro 128GB Black
- Men's Solid Polo blue Shirt Short with Collar Zipper
      ''';
  }
  return errorMessage;
}

void _navigateToSearchResults(
  BuildContext context,
  String input,
  List<ResultModel> results,
) {
  var _inUsePrompts = context.uniProvider.inUsePromptList;
  // Update user input in the prompt
  _inUsePrompts = _inUsePrompts
      .map((pBase) =>
          pBase.copyWith(content: pBase.content.replaceAll('[YOUR_INPUT]', input)))
      .toList();

  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => ResultsScreen(
              input,
              results,
              _inUsePrompts,
            )),
  );
}

Future<List<ResultModel>> _getGptResult(
  BuildContext context,
  String input, {
  String? translateTo,
}) async {
  final translator = GoogleTranslator();
  var _inUsePrompts = context.uniProvider.inUsePromptList;
  // print('_inUsePrompts ${_inUsePrompts}');
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

  if (kDebugMode && appConfig_fastHomeScreen) {
    results = dummyDataList;
  } else {
    results = await Gpt.getResults(
      context,
      type: ResultCategory.gResults,
      input: input,
      prompts: titlePrompts,
      gDescPrompts: gDescPrompts,
    );
    // reset loader on finish
    context.uniProvider.updateTextstoreBarLoader(0.0);
  }

  return results;
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

Future<List<WooPostModel>> getAllUserPrompts(WooUserModel currUser) async {
  var postList =
      await WooApi.getPosts(userId: currUser.id.toString(), catIds: promptsCategoryIds);
  postList = setDefaultPromptFirst(postList);
  return postList;
}

const dummyDataList = [
  ResultModel(
    title: longDescSample,
    category: ResultCategory.longDesc,
  ),

  // ResultModel(
  //     title: 'C A great google result title will appear here',
  //     desc:
  //         'C A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence.',
  //     category: ResultCategory.gResults),
  // ResultModel(
  //     title: 'C A great google result title will appear here',
  //     desc:
  //         'C A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence.',
  //     category: ResultCategory.gResults),
  // ResultModel(
  //     title: 'C A great google result title will appear here',
  //     desc:
  //         'C A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence.',
  //     category: ResultCategory.gResults),
];

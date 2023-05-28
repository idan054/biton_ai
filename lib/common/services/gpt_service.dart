// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:biton_ai/common/extensions/context_ext.dart';
import 'package:biton_ai/common/models/post/woo_post_model.dart';
import 'package:biton_ai/common/models/prompt/result_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/gpt/chat_gpt_model.dart';
import 'color_printer.dart';

class Gpt {
  static Future<List<ResultModel>> getResults(
    BuildContext context, {
    required ResultCategory type,
    required List<String> prompts,
    List<String>? gDescPrompts,
    required String input,
    // required int n,
  }) async {
    assert(type != ResultCategory.gResults || gDescPrompts != null,
        'gDescPrompts is required when type is ResultCategory.gResults');

    printWhite('START: getResults(): ${type.name}');
    print('${prompts.length} prompts: $prompts');

    // .toSet() retrieve only unique items
    prompts = prompts.toSet().toList();
    bool isSamePrompts = prompts.length == 1;

    // bool isSamePrompts = false; //> DEBUG
    // print('isSamePrompts ${isSamePrompts}');

    List<ResultModel> results = [];
    ChatGptModel? titles;
    ChatGptModel? descriptions;
    const ver = 3;
    titles = isSamePrompts
        ? await _singleCallChatGPT(context,
            reqType: type, n: 3, prompt: prompts.first, model: ver)
        //
        : await _multiCallChatGPT(context, reqType: type, prompts: prompts, model: ver);

    if (type == ResultCategory.gResults) {
      descriptions = isSamePrompts
          ? await _singleCallChatGPT(context,
              model: ver, reqType: type, gDescription: true, n: 3, prompt: prompts.first)
          //
          : await _multiCallChatGPT(context,
              model: ver, reqType: type, gDescription: true, prompts: gDescPrompts!);
    }

    var i = 0;
    for (var _ in titles.choices) {
      var result = ResultModel(
        category: type,
        title: titles.choices[i].toString().trim(),
        desc: descriptions?.choices[i].toString().trim(),
      );
      results.add(result);
      i++;
    }
    return results;
  }

  /// _multiCallChatGPT() So prompts can be different
  static Future<ChatGptModel> _multiCallChatGPT(
    BuildContext context, {
    ResultCategory? reqType,
    bool gDescription = false,
    required int model, // 3 & 4 available
    required List<String> prompts,
  }) async {
    printWhite('START: _multiCallChatGPT() | ${reqType?.name}');

    var type = '${reqType?.name.toUpperCase()}';
    if (gDescription) type += ' - Descriptions';

    try {
      var gptResponses = <ChatGptModel>[];
      var i = 0;
      for (var prompt in [...prompts]) {
        i++;
        // print('($reqType) prompt: $prompt');
        var url = '$baseUrl/ai-engine/v1/call-chat-gpt-$model';
        final headers = {'Content-Type': 'application/json'};
        final body = json.encode({'prompt': prompt, 'n': 1});
        final response = await http.post(Uri.parse(url), headers: headers, body: body);
        var counter = '[$i/${prompts.length}]';

        if (response.statusCode == 200) {
          printGreen(
              '($type) $counter response.statusCode ${response.statusCode} [GPT$model]');
          _updateTextStoreLoader(context, reqType!, prompts.length);

          final jsonResponse = json.decode(response.body);
          /**/ // print('jsonResponse $jsonResponse');
          var gptResp = ChatGptModel.fromJson(jsonResponse);
          print('($type) $counter gptModel.tokenUsage ${gptResp.tokenUsage}');
          gptResponses.add(gptResp);
        } else {
          throw Exception('Something went wrong. Please try again');
        }
      }

      var tempList = [];
      var fullGptModel = ChatGptModel(tokenUsage: 0, choices: [], model: ''); // Base only
      for (var gptResp in gptResponses) {
        tempList.addAll(gptResp.choices);
        fullGptModel = fullGptModel.copyWith(
            tokenUsage: fullGptModel.tokenUsage + gptResp.tokenUsage,
            choices: tempList,
            model: gptResp.model);
      }
      return fullGptModel;
    } catch (e, s) {
      print('e $e');
      // USAGE: _multiCallChatGPT.catchError((error) {)
      throw Exception('Something went wrong. Please try again');
    }
  }

  static void _updateTextStoreLoader(
      BuildContext context, ResultCategory reqType, int x) {
    if (reqType == ResultCategory.gResults) {
      var bonus = (1 / (x * 2));
      print('bonus ${bonus}');
      context.uniProvider
          .updateTextstoreBarLoader(context.uniProvider.textstoreBarLoader + bonus);
    }
  }

  // Make GPT Functions in this class
  static Future<ChatGptModel> _singleCallChatGPT(
    BuildContext context, {
    ResultCategory? reqType, // As Request PRINT name
    required String prompt,
    required int n,
    required int model, // 3 & 4 available
    bool gDescription = false,
  }) async {
    // print('\nSTART: callChatGPT()');
    printYellow('prompt: $prompt');
    var type = '${reqType?.name.toUpperCase()}';
    if (gDescription) type += ' - Descriptions';

    _updateTextStoreLoader(context, reqType!, 1);
    var url = '$baseUrl/ai-engine/v1/call-chat-gpt-$model';
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({'prompt': prompt, 'n': n});
    final response = await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      printGreen('($type) Single response.statusCode ${response.statusCode} [GPT$model]');

      final jsonResponse = json.decode(response.body);
      var gptModel = ChatGptModel.fromJson(jsonResponse);
      print('gptModel.tokenUsage ${gptModel.tokenUsage}');
      return gptModel;
    } else {
      throw Exception('Failed to call API');
    }
  }
}

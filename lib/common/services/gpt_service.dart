import 'dart:convert';
import 'package:biton_ai/common/models/post/woo_post_model.dart';
import 'package:biton_ai/common/models/prompt/result_model.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/gpt/chat_gpt_model.dart';
import 'color_printer.dart';

class Gpt {
  static Future<List<ResultModel>> getResults({
    required ResultCategory type,
    required String input,
    required int n,
  }) async {
    print('\nSTART: getResults: ${type.name}');

    List<ResultModel> results = [];
    ChatGPTModel? titles;
    ChatGPTModel? descriptions;

    String? promptBase;
    switch (type) {
      case ResultCategory.titles:
        promptBase = 'Create a great product title of 1-2 lines for:';
        break;
      case ResultCategory.gResults:
        promptBase = 'Create a great google title for the product:';
        break;
      case ResultCategory.shortDesc:
        promptBase = 'Create a short SEO description of 3-5 lines about:';
        break;
      case ResultCategory.longDesc:
        promptBase = 'Create a long SEO description of 20-30 lines about:';
    }

    titles = await _callChatGPT(
      prompt: '$promptBase $input',
      reqType: type.name.toUpperCase(),
      n: n,
    );

    if (type == ResultCategory.gResults) {
      descriptions = await _callChatGPT(
        n: n,
        reqType: '${type.name} - Descriptions',
        prompt: 'Create a great google description for the product: $input',
      );
    }

    var i = 0;
    for (var _ in titles.choices) {
      var result = ResultModel(
        category: type,
        title: titles.choices[i],
        desc: descriptions?.choices[i],
      );
      results.add(result);
      i++;
    }
    return results;
  }

  // So prompts can be different
  // static Future<ChatGPTModel> _multiCallChatGPT({
  //   String? reqType,
  //   required List<String> prompts,
  // }) async {
  //   print('START: _multiCallChatGPT()');
  //
  //   var gptResponses = <ChatGPTModel>[];
  //   for (var prompt in [...prompts]) {
  //     printYellow('prompt: $prompt');
  //     const url = '$baseUrl/ai-engine/v1/call-chat-gpt';
  //     final headers = {'Content-Type': 'application/json'};
  //     final body = json.encode({'prompt': prompt, 'n': 1});
  //     final response = await http.post(Uri.parse(url), headers: headers, body: body);
  //
  //     if (response.statusCode == 200) {
  //       printGreen('response.statusCode ${response.statusCode} ($reqType)');
  //       final jsonResponse = json.decode(response.body);
  //       var gptResp = ChatGPTModel.fromJson(jsonResponse);
  //       print('gptModel.tokenUsage ${gptResp.tokenUsage}');
  //       gptResponses.add(gptResp);
  //     } else {
  //       throw Exception('Failed to call API');
  //     }
  //   }
  //
  //   var fullGptModel = ChatGPTModel(tokenUsage: 0, choices: []);
  //   for (var gptResp in gptResponses) {
  //     fullGptModel.choices.addAll(gptResp.choices);
  //     fullGptModel =
  //         fullGptModel.copyWith(tokenUsage: fullGptModel.tokenUsage + gptResp.tokenUsage);
  //   }
  //
  //   return fullGptModel;
  // }

  // Make GPT Functions in this class
  static Future<ChatGPTModel> _callChatGPT({
    String? reqType, // As Request PRINT name
    required String prompt,
    required int n,
  }) async {
    // print('\nSTART: callChatGPT()');
    printYellow('prompt: $prompt');

    const url = '$baseUrl/ai-engine/v1/call-chat-gpt';
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({'prompt': prompt, 'n': n});
    final response = await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      printGreen('response.statusCode ${response.statusCode} ($reqType)');
      final jsonResponse = json.decode(response.body);
      var gptModel = ChatGPTModel.fromJson(jsonResponse);
      print('gptModel.tokenUsage ${gptModel.tokenUsage}');
      return gptModel;
    } else {
      throw Exception('Failed to call API');
    }
  }
}

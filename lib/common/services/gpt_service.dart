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
    required List<String> prompts,
    List<String>? gDescPrompts,
    required String input,
    // required int n,
  }) async {
    assert(type != ResultCategory.gResults || gDescPrompts != null,
        'gDescPrompts is required when type is ResultCategory.gResults');

    print('START: getResults: ${type.name}');

    List<ResultModel> results = [];
    ChatGPTModel? titles;
    ChatGPTModel? descriptions;

    titles = await _multiCallChatGPT(
      reqType: type.name.toUpperCase(),
      prompts: type == ResultCategory.longDesc ? [prompts.first] : prompts,
    );

    if (type == ResultCategory.gResults) {
      descriptions = await _multiCallChatGPT(
        reqType: '${type.name} - Descriptions',
        prompts: gDescPrompts!,
      );
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
  static Future<ChatGPTModel> _multiCallChatGPT({
    String? reqType,
    required List<String> prompts,
  }) async {
    printWhite('START: _multiCallChatGPT()');

    var gptResponses = <ChatGPTModel>[];
    var i = 0;
    for (var prompt in [...prompts]) {
      i++;
      print('($reqType) prompt: $prompt');
      const url = '$baseUrl/ai-engine/v1/call-chat-gpt';
      final headers = {'Content-Type': 'application/json'};
      final body = json.encode({'prompt': prompt, 'n': 1});
      final response = await http.post(Uri.parse(url), headers: headers, body: body);
      var counter = '[$i/${prompts.length}]';

      if (response.statusCode == 200) {
        printGreen('($reqType) $counter response.statusCode ${response.statusCode}');
        final jsonResponse = json.decode(response.body);
        var gptResp = ChatGPTModel.fromJson(jsonResponse);
        print('($reqType) $counter gptModel.tokenUsage ${gptResp.tokenUsage}');
        gptResponses.add(gptResp);
      } else {
        throw Exception('Failed to call API');
      }
    }

    var tempList = [];
    var fullGptModel = ChatGPTModel(tokenUsage: 0, choices: []);
    for (var gptResp in gptResponses) {
      tempList.addAll(gptResp.choices);
      fullGptModel = fullGptModel.copyWith(
        tokenUsage: fullGptModel.tokenUsage + gptResp.tokenUsage,
        choices: tempList,
      );
    }

    return fullGptModel;
  }

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

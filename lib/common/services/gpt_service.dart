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
      case ResultCategory.googleResults:
        promptBase = 'Create a great google title for the product:';
        break;
      case ResultCategory.shortDesc:
        promptBase = 'Create a short SEO description of 3-5 lines about:';
        break;
      case ResultCategory.longDesc:
        promptBase = 'Create a long SEO description of 15-30 lines about:';
    }

    titles = await _callChatGPT(
        prompt: '$promptBase $input', n: n);

    if (type == ResultCategory.googleResults) {
      descriptions = await _callChatGPT(
          prompt: 'Create a great google description for the product: $input', n: n);
    }

    var i = 0;
    for (var _ in titles.choices) {
      var result = ResultModel(
        category: ResultCategory.googleResults,
        title: titles.choices[i],
        desc: descriptions?.choices[i],
      );
      results.add(result);
      i++;
    }
    return results;
  }

  // Make GPT Functions in this class
  static Future<ChatGPTModel> _callChatGPT(
      {required String prompt, required int n}) async {
    // print('\nSTART: callChatGPT()');
    printYellow('prompt: $prompt');

    const url = '$baseUrl/ai-engine/v1/call-chat-gpt';
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({'prompt': prompt, 'n': n});
    final response = await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      printGreen('response.statusCode ${response.statusCode}');
      final jsonResponse = json.decode(response.body);
      var gptModel = ChatGPTModel.fromJson(jsonResponse);
      return gptModel;
    } else {
      throw Exception('Failed to call API');
    }
  }
}

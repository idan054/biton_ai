import 'package:freezed_annotation/freezed_annotation.dart';
import '../../services/convertors.dart';

part 'chat_gpt_model.freezed.dart';

part 'chat_gpt_model.g.dart';

@freezed
class ChatGptModel with _$ChatGptModel {
  @JsonSerializable()
  factory ChatGptModel({
    @JsonKey(name: 'model') required String model,
    @JsonKey(name: 'choices', fromJson: fetchChoicesFromJson) required List choices,
    @JsonKey(name: 'usage', fromJson: fetchUsageFromJson) required int tokenUsage,
  }) = _ChatGptModel;

  factory ChatGptModel.fromJson(Map<String, dynamic> json) =>
      _$ChatGptModelFromJson(json);
}

// ["usage"]["total_tokens"]
dynamic fetchUsageFromJson(Map<String, dynamic> usage) => usage['total_tokens'];

// ["choices"][i]["message"]["content"] (OR) ["choices"][i]["text"]
dynamic fetchChoicesFromJson(List choices) {
  var results = [];
  if (choices.isNotEmpty) {
    for (Map choice in choices) {
      dynamic content;

      if (choice.containsKey('message')) {
        //~ Chat GPT 3.5 Turbo
        content = choice['message']['content'];
      } else {
        //~ Chat GPT 4 Devinci
        content = choice['text'];
      }
      results.add(content);
    }
  }
  return results;
}

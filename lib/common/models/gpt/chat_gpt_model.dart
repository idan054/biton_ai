import 'package:freezed_annotation/freezed_annotation.dart';

import '../../services/convertors.dart';

part 'chat_gpt_model.freezed.dart';

part 'chat_gpt_model.g.dart';

@freezed
class ChatGPTModel with _$ChatGPTModel {
  @JsonSerializable()
  factory ChatGPTModel({

    @JsonKey(name: 'choices', fromJson: fetchChoicesFromJson)
    required List choices,

    @JsonKey(name: 'usage', fromJson: fetchUsageFromJson)
    required int tokenUsage,

  }) = _ChatGPTModel;

  factory ChatGPTModel.fromJson(Map<String, dynamic> json) =>
      _$ChatGPTModelFromJson(json);
}

// ["usage"]["total_tokens"]
dynamic fetchUsageFromJson(Map<String, dynamic> usage) => usage['total_tokens'];

// ["choices"][i]["message"]["content"]
dynamic fetchChoicesFromJson(List choices) {
  var results = [];
  if (choices.isNotEmpty) {
    for(var choice in choices){
      var content = choice['message']['content'];
      results.add(content);
    }
  }
  return results;
}




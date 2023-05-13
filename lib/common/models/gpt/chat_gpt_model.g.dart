// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_gpt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ChatGptModel _$$_ChatGptModelFromJson(Map<String, dynamic> json) =>
    _$_ChatGptModel(
      model: json['model'] as String,
      choices: fetchChoicesFromJson(json['choices'] as List),
      tokenUsage: fetchUsageFromJson(json['usage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_ChatGptModelToJson(_$_ChatGptModel instance) =>
    <String, dynamic>{
      'model': instance.model,
      'choices': instance.choices,
      'usage': instance.tokenUsage,
    };

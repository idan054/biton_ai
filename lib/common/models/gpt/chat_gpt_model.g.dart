// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_gpt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ChatGPTModel _$$_ChatGPTModelFromJson(Map<String, dynamic> json) =>
    _$_ChatGPTModel(
      choices: fetchChoicesFromJson(json['choices'] as List),
      tokenUsage: fetchUsageFromJson(json['usage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_ChatGPTModelToJson(_$_ChatGPTModel instance) =>
    <String, dynamic>{
      'choices': instance.choices,
      'usage': instance.tokenUsage,
    };

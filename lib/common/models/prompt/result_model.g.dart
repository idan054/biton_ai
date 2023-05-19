// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ResultModel _$$_ResultModelFromJson(Map<String, dynamic> json) =>
    _$_ResultModel(
      category:
          $enumDecodeNullable(_$ResultCategoryEnumMap, json['category']) ??
              ResultCategory.gResults,
      title: json['title'] as String,
      desc: json['desc'] as String?,
    );

Map<String, dynamic> _$$_ResultModelToJson(_$_ResultModel instance) =>
    <String, dynamic>{
      'category': _$ResultCategoryEnumMap[instance.category],
      'title': instance.title,
      'desc': instance.desc,
    };

const _$ResultCategoryEnumMap = {
  ResultCategory.titles: 'titles',
  ResultCategory.gResults: 'gResults',
  ResultCategory.shortDesc: 'shortDesc',
  ResultCategory.longDesc: 'longDesc',
  ResultCategory.tags: 'tags',
};

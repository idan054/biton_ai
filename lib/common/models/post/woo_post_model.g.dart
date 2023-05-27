// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'woo_post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_WooPostModel _$$_WooPostModelFromJson(Map<String, dynamic> json) =>
    _$_WooPostModel(
      id: json['id'] as int?,
      author: json['author'] as int,
      categories:
          (json['categories'] as List<dynamic>).map((e) => e as int).toList(),
      category: $enumDecode(_$ResultCategoryEnumMap, json['category']),
      title: json['title'] as String,
      content: json['content'] as String,
      subContent: json['subContent'] as String?,
      isAdmin: json['isAdmin'] as bool? ?? false,
      isDefault: json['isDefault'] as bool? ?? false,
      isSelected: json['isSelected'] as bool? ?? false,
    );

Map<String, dynamic> _$$_WooPostModelToJson(_$_WooPostModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author': instance.author,
      'categories': instance.categories,
      'category': _$ResultCategoryEnumMap[instance.category]!,
      'title': instance.title,
      'content': instance.content,
      'subContent': instance.subContent,
      'isAdmin': instance.isAdmin,
      'isDefault': instance.isDefault,
      'isSelected': instance.isSelected,
    };

const _$ResultCategoryEnumMap = {
  ResultCategory.titles: 'titles',
  ResultCategory.gResults: 'gResults',
  ResultCategory.shortDesc: 'shortDesc',
  ResultCategory.longDesc: 'longDesc',
  ResultCategory.tags: 'tags',
};

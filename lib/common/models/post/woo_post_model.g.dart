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
      title: json['title'] as String,
      content: json['content'] as String,
      subContent: json['subContent'] as String?,
    );

Map<String, dynamic> _$$_WooPostModelToJson(_$_WooPostModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author': instance.author,
      'categories': instance.categories,
      'title': instance.title,
      'content': instance.content,
      'subContent': instance.subContent,
    };

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prompt_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$PromptModel {
  String get name => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  int get authorUid => throw _privateConstructorUsedError;
  int get categoryId => throw _privateConstructorUsedError;
  String? get categoryName => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PromptModelCopyWith<PromptModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PromptModelCopyWith<$Res> {
  factory $PromptModelCopyWith(
          PromptModel value, $Res Function(PromptModel) then) =
      _$PromptModelCopyWithImpl<$Res, PromptModel>;
  @useResult
  $Res call(
      {String name,
      String content,
      int authorUid,
      int categoryId,
      String? categoryName});
}

/// @nodoc
class _$PromptModelCopyWithImpl<$Res, $Val extends PromptModel>
    implements $PromptModelCopyWith<$Res> {
  _$PromptModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? content = null,
    Object? authorUid = null,
    Object? categoryId = null,
    Object? categoryName = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      authorUid: null == authorUid
          ? _value.authorUid
          : authorUid // ignore: cast_nullable_to_non_nullable
              as int,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int,
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_PromptModelCopyWith<$Res>
    implements $PromptModelCopyWith<$Res> {
  factory _$$_PromptModelCopyWith(
          _$_PromptModel value, $Res Function(_$_PromptModel) then) =
      __$$_PromptModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String content,
      int authorUid,
      int categoryId,
      String? categoryName});
}

/// @nodoc
class __$$_PromptModelCopyWithImpl<$Res>
    extends _$PromptModelCopyWithImpl<$Res, _$_PromptModel>
    implements _$$_PromptModelCopyWith<$Res> {
  __$$_PromptModelCopyWithImpl(
      _$_PromptModel _value, $Res Function(_$_PromptModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? content = null,
    Object? authorUid = null,
    Object? categoryId = null,
    Object? categoryName = freezed,
  }) {
    return _then(_$_PromptModel(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      authorUid: null == authorUid
          ? _value.authorUid
          : authorUid // ignore: cast_nullable_to_non_nullable
              as int,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int,
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$_PromptModel implements _PromptModel {
  const _$_PromptModel(
      {required this.name,
      required this.content,
      required this.authorUid,
      required this.categoryId,
      this.categoryName});

  @override
  final String name;
  @override
  final String content;
  @override
  final int authorUid;
  @override
  final int categoryId;
  @override
  final String? categoryName;

  @override
  String toString() {
    return 'PromptModel(name: $name, content: $content, authorUid: $authorUid, categoryId: $categoryId, categoryName: $categoryName)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PromptModel &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.authorUid, authorUid) ||
                other.authorUid == authorUid) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, name, content, authorUid, categoryId, categoryName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PromptModelCopyWith<_$_PromptModel> get copyWith =>
      __$$_PromptModelCopyWithImpl<_$_PromptModel>(this, _$identity);
}

abstract class _PromptModel implements PromptModel {
  const factory _PromptModel(
      {required final String name,
      required final String content,
      required final int authorUid,
      required final int categoryId,
      final String? categoryName}) = _$_PromptModel;

  @override
  String get name;
  @override
  String get content;
  @override
  int get authorUid;
  @override
  int get categoryId;
  @override
  String? get categoryName;
  @override
  @JsonKey(ignore: true)
  _$$_PromptModelCopyWith<_$_PromptModel> get copyWith =>
      throw _privateConstructorUsedError;
}

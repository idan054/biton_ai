// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'result_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ResultModel _$ResultModelFromJson(Map<String, dynamic> json) {
  return _ResultModel.fromJson(json);
}

/// @nodoc
mixin _$ResultModel {
  ResultCategory? get category => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get translatedTitle => throw _privateConstructorUsedError;
  String? get desc => throw _privateConstructorUsedError;
  String? get translatedDesc => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ResultModelCopyWith<ResultModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResultModelCopyWith<$Res> {
  factory $ResultModelCopyWith(
          ResultModel value, $Res Function(ResultModel) then) =
      _$ResultModelCopyWithImpl<$Res, ResultModel>;
  @useResult
  $Res call(
      {ResultCategory? category,
      String title,
      String translatedTitle,
      String? desc,
      String? translatedDesc});
}

/// @nodoc
class _$ResultModelCopyWithImpl<$Res, $Val extends ResultModel>
    implements $ResultModelCopyWith<$Res> {
  _$ResultModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = freezed,
    Object? title = null,
    Object? translatedTitle = null,
    Object? desc = freezed,
    Object? translatedDesc = freezed,
  }) {
    return _then(_value.copyWith(
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ResultCategory?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      translatedTitle: null == translatedTitle
          ? _value.translatedTitle
          : translatedTitle // ignore: cast_nullable_to_non_nullable
              as String,
      desc: freezed == desc
          ? _value.desc
          : desc // ignore: cast_nullable_to_non_nullable
              as String?,
      translatedDesc: freezed == translatedDesc
          ? _value.translatedDesc
          : translatedDesc // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ResultModelCopyWith<$Res>
    implements $ResultModelCopyWith<$Res> {
  factory _$$_ResultModelCopyWith(
          _$_ResultModel value, $Res Function(_$_ResultModel) then) =
      __$$_ResultModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ResultCategory? category,
      String title,
      String translatedTitle,
      String? desc,
      String? translatedDesc});
}

/// @nodoc
class __$$_ResultModelCopyWithImpl<$Res>
    extends _$ResultModelCopyWithImpl<$Res, _$_ResultModel>
    implements _$$_ResultModelCopyWith<$Res> {
  __$$_ResultModelCopyWithImpl(
      _$_ResultModel _value, $Res Function(_$_ResultModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = freezed,
    Object? title = null,
    Object? translatedTitle = null,
    Object? desc = freezed,
    Object? translatedDesc = freezed,
  }) {
    return _then(_$_ResultModel(
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ResultCategory?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      translatedTitle: null == translatedTitle
          ? _value.translatedTitle
          : translatedTitle // ignore: cast_nullable_to_non_nullable
              as String,
      desc: freezed == desc
          ? _value.desc
          : desc // ignore: cast_nullable_to_non_nullable
              as String?,
      translatedDesc: freezed == translatedDesc
          ? _value.translatedDesc
          : translatedDesc // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ResultModel implements _ResultModel {
  const _$_ResultModel(
      {this.category = ResultCategory.gResults,
      required this.title,
      this.translatedTitle = '',
      this.desc,
      this.translatedDesc});

  factory _$_ResultModel.fromJson(Map<String, dynamic> json) =>
      _$$_ResultModelFromJson(json);

  @override
  @JsonKey()
  final ResultCategory? category;
  @override
  final String title;
  @override
  @JsonKey()
  final String translatedTitle;
  @override
  final String? desc;
  @override
  final String? translatedDesc;

  @override
  String toString() {
    return 'ResultModel(category: $category, title: $title, translatedTitle: $translatedTitle, desc: $desc, translatedDesc: $translatedDesc)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ResultModel &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.translatedTitle, translatedTitle) ||
                other.translatedTitle == translatedTitle) &&
            (identical(other.desc, desc) || other.desc == desc) &&
            (identical(other.translatedDesc, translatedDesc) ||
                other.translatedDesc == translatedDesc));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, category, title, translatedTitle, desc, translatedDesc);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ResultModelCopyWith<_$_ResultModel> get copyWith =>
      __$$_ResultModelCopyWithImpl<_$_ResultModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ResultModelToJson(
      this,
    );
  }
}

abstract class _ResultModel implements ResultModel {
  const factory _ResultModel(
      {final ResultCategory? category,
      required final String title,
      final String translatedTitle,
      final String? desc,
      final String? translatedDesc}) = _$_ResultModel;

  factory _ResultModel.fromJson(Map<String, dynamic> json) =
      _$_ResultModel.fromJson;

  @override
  ResultCategory? get category;
  @override
  String get title;
  @override
  String get translatedTitle;
  @override
  String? get desc;
  @override
  String? get translatedDesc;
  @override
  @JsonKey(ignore: true)
  _$$_ResultModelCopyWith<_$_ResultModel> get copyWith =>
      throw _privateConstructorUsedError;
}

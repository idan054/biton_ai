// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'woo_post_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$WooPostModel {
  int? get id =>
      throw _privateConstructorUsedError; // doesn't have while create
  int get author => throw _privateConstructorUsedError;
  List<int> get categories => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String? get subContent => throw _privateConstructorUsedError;
  bool get isDefault =>
      throw _privateConstructorUsedError; // name: on wordpress API
  @JsonKey(name: 'sticky')
  bool get isSelected => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $WooPostModelCopyWith<WooPostModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WooPostModelCopyWith<$Res> {
  factory $WooPostModelCopyWith(
          WooPostModel value, $Res Function(WooPostModel) then) =
      _$WooPostModelCopyWithImpl<$Res, WooPostModel>;
  @useResult
  $Res call(
      {int? id,
      int author,
      List<int> categories,
      String title,
      String content,
      String? subContent,
      bool isDefault,
      @JsonKey(name: 'sticky') bool isSelected});
}

/// @nodoc
class _$WooPostModelCopyWithImpl<$Res, $Val extends WooPostModel>
    implements $WooPostModelCopyWith<$Res> {
  _$WooPostModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? author = null,
    Object? categories = null,
    Object? title = null,
    Object? content = null,
    Object? subContent = freezed,
    Object? isDefault = null,
    Object? isSelected = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as int,
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<int>,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      subContent: freezed == subContent
          ? _value.subContent
          : subContent // ignore: cast_nullable_to_non_nullable
              as String?,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      isSelected: null == isSelected
          ? _value.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_WooPostModelCopyWith<$Res>
    implements $WooPostModelCopyWith<$Res> {
  factory _$$_WooPostModelCopyWith(
          _$_WooPostModel value, $Res Function(_$_WooPostModel) then) =
      __$$_WooPostModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      int author,
      List<int> categories,
      String title,
      String content,
      String? subContent,
      bool isDefault,
      @JsonKey(name: 'sticky') bool isSelected});
}

/// @nodoc
class __$$_WooPostModelCopyWithImpl<$Res>
    extends _$WooPostModelCopyWithImpl<$Res, _$_WooPostModel>
    implements _$$_WooPostModelCopyWith<$Res> {
  __$$_WooPostModelCopyWithImpl(
      _$_WooPostModel _value, $Res Function(_$_WooPostModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? author = null,
    Object? categories = null,
    Object? title = null,
    Object? content = null,
    Object? subContent = freezed,
    Object? isDefault = null,
    Object? isSelected = null,
  }) {
    return _then(_$_WooPostModel(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as int,
      categories: null == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<int>,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      subContent: freezed == subContent
          ? _value.subContent
          : subContent // ignore: cast_nullable_to_non_nullable
              as String?,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      isSelected: null == isSelected
          ? _value.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true, nullable: true)
class _$_WooPostModel implements _WooPostModel {
  _$_WooPostModel(
      {this.id,
      required this.author,
      required final List<int> categories,
      required this.title,
      required this.content,
      this.subContent,
      this.isDefault = false,
      @JsonKey(name: 'sticky') this.isSelected = false})
      : _categories = categories;

  @override
  final int? id;
// doesn't have while create
  @override
  final int author;
  final List<int> _categories;
  @override
  List<int> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  @override
  final String title;
  @override
  final String content;
  @override
  final String? subContent;
  @override
  @JsonKey()
  final bool isDefault;
// name: on wordpress API
  @override
  @JsonKey(name: 'sticky')
  final bool isSelected;

  @override
  String toString() {
    return 'WooPostModel(id: $id, author: $author, categories: $categories, title: $title, content: $content, subContent: $subContent, isDefault: $isDefault, isSelected: $isSelected)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_WooPostModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.author, author) || other.author == author) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.subContent, subContent) ||
                other.subContent == subContent) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      author,
      const DeepCollectionEquality().hash(_categories),
      title,
      content,
      subContent,
      isDefault,
      isSelected);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_WooPostModelCopyWith<_$_WooPostModel> get copyWith =>
      __$$_WooPostModelCopyWithImpl<_$_WooPostModel>(this, _$identity);
}

abstract class _WooPostModel implements WooPostModel {
  factory _WooPostModel(
      {final int? id,
      required final int author,
      required final List<int> categories,
      required final String title,
      required final String content,
      final String? subContent,
      final bool isDefault,
      @JsonKey(name: 'sticky') final bool isSelected}) = _$_WooPostModel;

  @override
  int? get id;
  @override // doesn't have while create
  int get author;
  @override
  List<int> get categories;
  @override
  String get title;
  @override
  String get content;
  @override
  String? get subContent;
  @override
  bool get isDefault;
  @override // name: on wordpress API
  @JsonKey(name: 'sticky')
  bool get isSelected;
  @override
  @JsonKey(ignore: true)
  _$$_WooPostModelCopyWith<_$_WooPostModel> get copyWith =>
      throw _privateConstructorUsedError;
}

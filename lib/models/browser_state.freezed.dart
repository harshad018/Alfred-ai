// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'browser_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BrowserState _$BrowserStateFromJson(Map<String, dynamic> json) {
  return _BrowserState.fromJson(json);
}

/// @nodoc
mixin _$BrowserState {
  String get currentUrl => throw _privateConstructorUsedError;
  String get pageTitle => throw _privateConstructorUsedError;
  String get pageContent => throw _privateConstructorUsedError;
  List<ElementInfo> get elements => throw _privateConstructorUsedError;
  String? get screenshotBase64 =>
      throw _privateConstructorUsedError; // Changed to String? instead of Uint8List?
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;
  List<String> get navigationHistory => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this BrowserState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BrowserState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BrowserStateCopyWith<BrowserState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BrowserStateCopyWith<$Res> {
  factory $BrowserStateCopyWith(
          BrowserState value, $Res Function(BrowserState) then) =
      _$BrowserStateCopyWithImpl<$Res, BrowserState>;
  @useResult
  $Res call(
      {String currentUrl,
      String pageTitle,
      String pageContent,
      List<ElementInfo> elements,
      String? screenshotBase64,
      Map<String, dynamic> metadata,
      List<String> navigationHistory,
      bool isLoading,
      DateTime? lastUpdated});
}

/// @nodoc
class _$BrowserStateCopyWithImpl<$Res, $Val extends BrowserState>
    implements $BrowserStateCopyWith<$Res> {
  _$BrowserStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BrowserState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentUrl = null,
    Object? pageTitle = null,
    Object? pageContent = null,
    Object? elements = null,
    Object? screenshotBase64 = freezed,
    Object? metadata = null,
    Object? navigationHistory = null,
    Object? isLoading = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      currentUrl: null == currentUrl
          ? _value.currentUrl
          : currentUrl // ignore: cast_nullable_to_non_nullable
              as String,
      pageTitle: null == pageTitle
          ? _value.pageTitle
          : pageTitle // ignore: cast_nullable_to_non_nullable
              as String,
      pageContent: null == pageContent
          ? _value.pageContent
          : pageContent // ignore: cast_nullable_to_non_nullable
              as String,
      elements: null == elements
          ? _value.elements
          : elements // ignore: cast_nullable_to_non_nullable
              as List<ElementInfo>,
      screenshotBase64: freezed == screenshotBase64
          ? _value.screenshotBase64
          : screenshotBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      navigationHistory: null == navigationHistory
          ? _value.navigationHistory
          : navigationHistory // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BrowserStateImplCopyWith<$Res>
    implements $BrowserStateCopyWith<$Res> {
  factory _$$BrowserStateImplCopyWith(
          _$BrowserStateImpl value, $Res Function(_$BrowserStateImpl) then) =
      __$$BrowserStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String currentUrl,
      String pageTitle,
      String pageContent,
      List<ElementInfo> elements,
      String? screenshotBase64,
      Map<String, dynamic> metadata,
      List<String> navigationHistory,
      bool isLoading,
      DateTime? lastUpdated});
}

/// @nodoc
class __$$BrowserStateImplCopyWithImpl<$Res>
    extends _$BrowserStateCopyWithImpl<$Res, _$BrowserStateImpl>
    implements _$$BrowserStateImplCopyWith<$Res> {
  __$$BrowserStateImplCopyWithImpl(
      _$BrowserStateImpl _value, $Res Function(_$BrowserStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of BrowserState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentUrl = null,
    Object? pageTitle = null,
    Object? pageContent = null,
    Object? elements = null,
    Object? screenshotBase64 = freezed,
    Object? metadata = null,
    Object? navigationHistory = null,
    Object? isLoading = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$BrowserStateImpl(
      currentUrl: null == currentUrl
          ? _value.currentUrl
          : currentUrl // ignore: cast_nullable_to_non_nullable
              as String,
      pageTitle: null == pageTitle
          ? _value.pageTitle
          : pageTitle // ignore: cast_nullable_to_non_nullable
              as String,
      pageContent: null == pageContent
          ? _value.pageContent
          : pageContent // ignore: cast_nullable_to_non_nullable
              as String,
      elements: null == elements
          ? _value._elements
          : elements // ignore: cast_nullable_to_non_nullable
              as List<ElementInfo>,
      screenshotBase64: freezed == screenshotBase64
          ? _value.screenshotBase64
          : screenshotBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      navigationHistory: null == navigationHistory
          ? _value._navigationHistory
          : navigationHistory // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BrowserStateImpl extends _BrowserState {
  const _$BrowserStateImpl(
      {required this.currentUrl,
      required this.pageTitle,
      required this.pageContent,
      required final List<ElementInfo> elements,
      this.screenshotBase64,
      required final Map<String, dynamic> metadata,
      final List<String> navigationHistory = const [],
      this.isLoading = false,
      this.lastUpdated})
      : _elements = elements,
        _metadata = metadata,
        _navigationHistory = navigationHistory,
        super._();

  factory _$BrowserStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$BrowserStateImplFromJson(json);

  @override
  final String currentUrl;
  @override
  final String pageTitle;
  @override
  final String pageContent;
  final List<ElementInfo> _elements;
  @override
  List<ElementInfo> get elements {
    if (_elements is EqualUnmodifiableListView) return _elements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_elements);
  }

  @override
  final String? screenshotBase64;
// Changed to String? instead of Uint8List?
  final Map<String, dynamic> _metadata;
// Changed to String? instead of Uint8List?
  @override
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  final List<String> _navigationHistory;
  @override
  @JsonKey()
  List<String> get navigationHistory {
    if (_navigationHistory is EqualUnmodifiableListView)
      return _navigationHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_navigationHistory);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'BrowserState(currentUrl: $currentUrl, pageTitle: $pageTitle, pageContent: $pageContent, elements: $elements, screenshotBase64: $screenshotBase64, metadata: $metadata, navigationHistory: $navigationHistory, isLoading: $isLoading, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BrowserStateImpl &&
            (identical(other.currentUrl, currentUrl) ||
                other.currentUrl == currentUrl) &&
            (identical(other.pageTitle, pageTitle) ||
                other.pageTitle == pageTitle) &&
            (identical(other.pageContent, pageContent) ||
                other.pageContent == pageContent) &&
            const DeepCollectionEquality().equals(other._elements, _elements) &&
            (identical(other.screenshotBase64, screenshotBase64) ||
                other.screenshotBase64 == screenshotBase64) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            const DeepCollectionEquality()
                .equals(other._navigationHistory, _navigationHistory) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentUrl,
      pageTitle,
      pageContent,
      const DeepCollectionEquality().hash(_elements),
      screenshotBase64,
      const DeepCollectionEquality().hash(_metadata),
      const DeepCollectionEquality().hash(_navigationHistory),
      isLoading,
      lastUpdated);

  /// Create a copy of BrowserState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BrowserStateImplCopyWith<_$BrowserStateImpl> get copyWith =>
      __$$BrowserStateImplCopyWithImpl<_$BrowserStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BrowserStateImplToJson(
      this,
    );
  }
}

abstract class _BrowserState extends BrowserState {
  const factory _BrowserState(
      {required final String currentUrl,
      required final String pageTitle,
      required final String pageContent,
      required final List<ElementInfo> elements,
      final String? screenshotBase64,
      required final Map<String, dynamic> metadata,
      final List<String> navigationHistory,
      final bool isLoading,
      final DateTime? lastUpdated}) = _$BrowserStateImpl;
  const _BrowserState._() : super._();

  factory _BrowserState.fromJson(Map<String, dynamic> json) =
      _$BrowserStateImpl.fromJson;

  @override
  String get currentUrl;
  @override
  String get pageTitle;
  @override
  String get pageContent;
  @override
  List<ElementInfo> get elements;
  @override
  String? get screenshotBase64; // Changed to String? instead of Uint8List?
  @override
  Map<String, dynamic> get metadata;
  @override
  List<String> get navigationHistory;
  @override
  bool get isLoading;
  @override
  DateTime? get lastUpdated;

  /// Create a copy of BrowserState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BrowserStateImplCopyWith<_$BrowserStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ElementInfo _$ElementInfoFromJson(Map<String, dynamic> json) {
  return _ElementInfo.fromJson(json);
}

/// @nodoc
mixin _$ElementInfo {
  int get index => throw _privateConstructorUsedError;
  String get tag => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  String get innerHtml => throw _privateConstructorUsedError;
  Map<String, String> get attributes => throw _privateConstructorUsedError;
  bool get isInteractive => throw _privateConstructorUsedError;
  Map<String, double> get boundingBox => throw _privateConstructorUsedError;

  /// Serializes this ElementInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ElementInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ElementInfoCopyWith<ElementInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ElementInfoCopyWith<$Res> {
  factory $ElementInfoCopyWith(
          ElementInfo value, $Res Function(ElementInfo) then) =
      _$ElementInfoCopyWithImpl<$Res, ElementInfo>;
  @useResult
  $Res call(
      {int index,
      String tag,
      String text,
      String innerHtml,
      Map<String, String> attributes,
      bool isInteractive,
      Map<String, double> boundingBox});
}

/// @nodoc
class _$ElementInfoCopyWithImpl<$Res, $Val extends ElementInfo>
    implements $ElementInfoCopyWith<$Res> {
  _$ElementInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ElementInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? tag = null,
    Object? text = null,
    Object? innerHtml = null,
    Object? attributes = null,
    Object? isInteractive = null,
    Object? boundingBox = null,
  }) {
    return _then(_value.copyWith(
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      tag: null == tag
          ? _value.tag
          : tag // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      innerHtml: null == innerHtml
          ? _value.innerHtml
          : innerHtml // ignore: cast_nullable_to_non_nullable
              as String,
      attributes: null == attributes
          ? _value.attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      isInteractive: null == isInteractive
          ? _value.isInteractive
          : isInteractive // ignore: cast_nullable_to_non_nullable
              as bool,
      boundingBox: null == boundingBox
          ? _value.boundingBox
          : boundingBox // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ElementInfoImplCopyWith<$Res>
    implements $ElementInfoCopyWith<$Res> {
  factory _$$ElementInfoImplCopyWith(
          _$ElementInfoImpl value, $Res Function(_$ElementInfoImpl) then) =
      __$$ElementInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int index,
      String tag,
      String text,
      String innerHtml,
      Map<String, String> attributes,
      bool isInteractive,
      Map<String, double> boundingBox});
}

/// @nodoc
class __$$ElementInfoImplCopyWithImpl<$Res>
    extends _$ElementInfoCopyWithImpl<$Res, _$ElementInfoImpl>
    implements _$$ElementInfoImplCopyWith<$Res> {
  __$$ElementInfoImplCopyWithImpl(
      _$ElementInfoImpl _value, $Res Function(_$ElementInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ElementInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? tag = null,
    Object? text = null,
    Object? innerHtml = null,
    Object? attributes = null,
    Object? isInteractive = null,
    Object? boundingBox = null,
  }) {
    return _then(_$ElementInfoImpl(
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      tag: null == tag
          ? _value.tag
          : tag // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      innerHtml: null == innerHtml
          ? _value.innerHtml
          : innerHtml // ignore: cast_nullable_to_non_nullable
              as String,
      attributes: null == attributes
          ? _value._attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      isInteractive: null == isInteractive
          ? _value.isInteractive
          : isInteractive // ignore: cast_nullable_to_non_nullable
              as bool,
      boundingBox: null == boundingBox
          ? _value._boundingBox
          : boundingBox // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ElementInfoImpl extends _ElementInfo {
  const _$ElementInfoImpl(
      {required this.index,
      required this.tag,
      required this.text,
      required this.innerHtml,
      required final Map<String, String> attributes,
      required this.isInteractive,
      required final Map<String, double> boundingBox})
      : _attributes = attributes,
        _boundingBox = boundingBox,
        super._();

  factory _$ElementInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ElementInfoImplFromJson(json);

  @override
  final int index;
  @override
  final String tag;
  @override
  final String text;
  @override
  final String innerHtml;
  final Map<String, String> _attributes;
  @override
  Map<String, String> get attributes {
    if (_attributes is EqualUnmodifiableMapView) return _attributes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_attributes);
  }

  @override
  final bool isInteractive;
  final Map<String, double> _boundingBox;
  @override
  Map<String, double> get boundingBox {
    if (_boundingBox is EqualUnmodifiableMapView) return _boundingBox;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_boundingBox);
  }

  @override
  String toString() {
    return 'ElementInfo(index: $index, tag: $tag, text: $text, innerHtml: $innerHtml, attributes: $attributes, isInteractive: $isInteractive, boundingBox: $boundingBox)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ElementInfoImpl &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.tag, tag) || other.tag == tag) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.innerHtml, innerHtml) ||
                other.innerHtml == innerHtml) &&
            const DeepCollectionEquality()
                .equals(other._attributes, _attributes) &&
            (identical(other.isInteractive, isInteractive) ||
                other.isInteractive == isInteractive) &&
            const DeepCollectionEquality()
                .equals(other._boundingBox, _boundingBox));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      index,
      tag,
      text,
      innerHtml,
      const DeepCollectionEquality().hash(_attributes),
      isInteractive,
      const DeepCollectionEquality().hash(_boundingBox));

  /// Create a copy of ElementInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ElementInfoImplCopyWith<_$ElementInfoImpl> get copyWith =>
      __$$ElementInfoImplCopyWithImpl<_$ElementInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ElementInfoImplToJson(
      this,
    );
  }
}

abstract class _ElementInfo extends ElementInfo {
  const factory _ElementInfo(
      {required final int index,
      required final String tag,
      required final String text,
      required final String innerHtml,
      required final Map<String, String> attributes,
      required final bool isInteractive,
      required final Map<String, double> boundingBox}) = _$ElementInfoImpl;
  const _ElementInfo._() : super._();

  factory _ElementInfo.fromJson(Map<String, dynamic> json) =
      _$ElementInfoImpl.fromJson;

  @override
  int get index;
  @override
  String get tag;
  @override
  String get text;
  @override
  String get innerHtml;
  @override
  Map<String, String> get attributes;
  @override
  bool get isInteractive;
  @override
  Map<String, double> get boundingBox;

  /// Create a copy of ElementInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ElementInfoImplCopyWith<_$ElementInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

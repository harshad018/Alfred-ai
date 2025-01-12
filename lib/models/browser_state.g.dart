// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browser_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BrowserStateImpl _$$BrowserStateImplFromJson(Map<String, dynamic> json) =>
    _$BrowserStateImpl(
      currentUrl: json['currentUrl'] as String,
      pageTitle: json['pageTitle'] as String,
      pageContent: json['pageContent'] as String,
      elements: (json['elements'] as List<dynamic>)
          .map((e) => ElementInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      screenshotBase64: json['screenshotBase64'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>,
      navigationHistory: (json['navigationHistory'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isLoading: json['isLoading'] as bool? ?? false,
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$BrowserStateImplToJson(_$BrowserStateImpl instance) =>
    <String, dynamic>{
      'currentUrl': instance.currentUrl,
      'pageTitle': instance.pageTitle,
      'pageContent': instance.pageContent,
      'elements': instance.elements,
      'screenshotBase64': instance.screenshotBase64,
      'metadata': instance.metadata,
      'navigationHistory': instance.navigationHistory,
      'isLoading': instance.isLoading,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };

_$ElementInfoImpl _$$ElementInfoImplFromJson(Map<String, dynamic> json) =>
    _$ElementInfoImpl(
      index: (json['index'] as num).toInt(),
      tag: json['tag'] as String,
      text: json['text'] as String,
      innerHtml: json['innerHtml'] as String,
      attributes: Map<String, String>.from(json['attributes'] as Map),
      isInteractive: json['isInteractive'] as bool,
      boundingBox: (json['boundingBox'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$$ElementInfoImplToJson(_$ElementInfoImpl instance) =>
    <String, dynamic>{
      'index': instance.index,
      'tag': instance.tag,
      'text': instance.text,
      'innerHtml': instance.innerHtml,
      'attributes': instance.attributes,
      'isInteractive': instance.isInteractive,
      'boundingBox': instance.boundingBox,
    };

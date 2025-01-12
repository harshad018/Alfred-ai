// lib/models/browser_state.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'browser_state.freezed.dart';
part 'browser_state.g.dart';

@freezed
class BrowserState with _$BrowserState {
  const BrowserState._();

  // Store screenshot as base64 String in the model
  const factory BrowserState({
    required String currentUrl,
    required String pageTitle,
    required String pageContent,
    required List<ElementInfo> elements,
    String? screenshotBase64,  // Changed to String? instead of Uint8List?
    required Map<String, dynamic> metadata,
    @Default([]) List<String> navigationHistory,
    @Default(false) bool isLoading,
    DateTime? lastUpdated,
  }) = _BrowserState;

  factory BrowserState.fromJson(Map<String, dynamic> json) => 
      _$BrowserStateFromJson(json);

  static BrowserState initial() => const BrowserState(
    currentUrl: '',
    pageTitle: '',
    pageContent: '',
    elements: [],
    screenshotBase64: null,
    metadata: {},
    navigationHistory: [],
    isLoading: false,
    lastUpdated: null,
  );

  // Add methods to handle Uint8List conversion
  Uint8List? get screenshot => 
      screenshotBase64 != null ? base64Decode(screenshotBase64!) : null;

  static BrowserState fromScreenshot(BrowserState state, Uint8List? screenshot) {
    return state.copyWith(
      screenshotBase64: screenshot != null ? base64Encode(screenshot) : null,
    );
  }
}

@freezed
class ElementInfo with _$ElementInfo {
  const ElementInfo._();

  const factory ElementInfo({
    required int index,
    required String tag,
    required String text,
    required String innerHtml,
    required Map<String, String> attributes,
    required bool isInteractive,
    required Map<String, double> boundingBox,
  }) = _ElementInfo;

  factory ElementInfo.fromJson(Map<String, dynamic> json) => 
      _$ElementInfoFromJson(json);
}
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:puppeteer/puppeteer.dart' as p;
import '../models/browser_state.dart';
import '../config/app_config.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';

class BrowserConfig {
  final String? chromePath;
  final bool headless;
  final List<String> arguments;
  final int viewportWidth;
  final int viewportHeight;
  final double deviceScaleFactor;

  BrowserConfig({
    this.chromePath,
    this.headless = false,
    this.arguments = const ['--no-sandbox', '--start-maximized'],
    this.viewportWidth = 1920,
    this.viewportHeight = 1080,
    this.deviceScaleFactor = 1.0,
  });
}

class Browser {
  p.Browser? _browser;
  p.Page? _page;

    // Add protected getter for page access
  @protected
  p.Page? get page => _page;

   // Add protected setter for page
  @protected
  set page(p.Page? value) {
    _page = value;
  }
  final _logger = Logger('Browser');
  final List<String> _navigationHistory = [];

  bool get isInitialized => _browser != null && _page != null;

  Future<void> initialize(BrowserConfig config) async {
    try {
      _logger.info('[${AppConfig.currentUserLogin}] Initializing browser');
      
      _browser = await p.puppeteer.launch(
        headless: config.headless,
        args: config.arguments,
        executablePath: config.chromePath,
      );

      _page = await _browser?.newPage();
      
      if (_page == null) {
        throw Exception('Failed to create new page');
      }

      final viewport = p.DeviceViewport(
        width: config.viewportWidth,
        height: config.viewportHeight,
        deviceScaleFactor: config.deviceScaleFactor,
      );

      await _page!.setViewport(viewport);

      // Set default headers
      

      _logger.info('[${AppConfig.currentUserLogin}] Browser initialized successfully');
    } catch (e, stackTrace) {
      _logger.severe('[${AppConfig.currentUserLogin}] Failed to initialize browser', e, stackTrace);
      rethrow;
    }
  }

  // lib/core/browser.dart

  Future<BrowserState> getCurrentState() async {
    if (!isInitialized) {
      throw Exception('Browser not initialized');
    }

    try {
      String currentUrl = '';
      String pageTitle = '';

      if (_page != null) {
        currentUrl = await _page!.evaluate('window.location.href') as String? ?? '';
        pageTitle = await _page!.evaluate('document.title') as String? ?? '';
      }

      final screenshot = await _takeScreenshot();
      final content = await _getPageContent();
      final elements = await _getPageElements();
      
      final state = BrowserState(
        currentUrl: currentUrl,
        pageTitle: pageTitle,
        pageContent: content,
        elements: elements,
        screenshotBase64: null,  // Initially set to null
        metadata: await _getPageMetadata(),
        lastUpdated: DateTime.now(),
      );

      // Convert and set screenshot
      return BrowserState.fromScreenshot(state, screenshot);
    } catch (e, stackTrace) {
      _logger.severe('Failed to get current state', e, stackTrace);
      rethrow;
    }
  }

  Future<Uint8List?> _takeScreenshot() async {
    if (_page == null) return null;

    try {
      final bytes = await _page!.screenshot();
      return bytes;
    } catch (e) {
      _logger.warning('Failed to take screenshot', e);
      return null;
    }
  }
  Future<String> _getPageContent() async {
    if (_page == null) return '';

    try {
      final content = await _page!.evaluate('document.documentElement.outerHTML') as String? ?? '';
      return content;
    } catch (e) {
      _logger.warning('[${AppConfig.currentUserLogin}] Failed to get page content', e);
      return '';
    }
  }

  Future<List<ElementInfo>> _getPageElements() async {
    if (_page == null) return [];

    try {
      final result = await _page!.evaluate('''
        () => {
          return Array.from(document.querySelectorAll('*')).map((el, index) => ({
            index: index,
            tag: el.tagName.toLowerCase(),
            text: el.textContent || '',
            innerHtml: el.innerHTML,
            attributes: Object.assign({}, ...Array.from(el.attributes).map(attr => ({
              [attr.name]: attr.value
            }))),
            isInteractive: ['a', 'button', 'input', 'select', 'textarea']
              .includes(el.tagName.toLowerCase()),
            boundingBox: el.getBoundingClientRect() ? {
              x: el.getBoundingClientRect().x,
              y: el.getBoundingClientRect().y,
              width: el.getBoundingClientRect().width,
              height: el.getBoundingClientRect().height
            } : null
          }));
        }
      ''');

      if (result == null) return [];

      return (result as List).map((element) => ElementInfo(
        index: element['index'] as int,
        tag: element['tag'] as String,
        text: element['text'] as String,
        innerHtml: element['innerHtml'] as String,
        attributes: Map<String, String>.from(element['attributes'] as Map),
        isInteractive: element['isInteractive'] as bool,
        boundingBox: Map<String, double>.from(element['boundingBox'] ?? {
          'x': 0.0,
          'y': 0.0,
          'width': 0.0,
          'height': 0.0
        }),
      )).toList();
    } catch (e, stackTrace) {
      _logger.severe('[${AppConfig.currentUserLogin}] Failed to get page elements', e, stackTrace);
      return [];
    }
  }

  Future<Map<String, dynamic>> _getPageMetadata() async {
    if (_page == null) return {};

    try {
      final result = await _page!.evaluate('''
        () => ({
          title: document.title,
          description: document.querySelector('meta[name="description"]')?.content,
          viewport: document.querySelector('meta[name="viewport"]')?.content,
          documentHeight: document.documentElement.scrollHeight,
          documentWidth: document.documentElement.scrollWidth,
          timestamp: "${DateFormat('yyyy-MM-dd HH:mm:ss').format(AppConfig.currentUtcTime)} UTC",
          user: "${AppConfig.currentUserLogin}"
        })
      ''') as Map<String, dynamic>?;

      return result ?? {};
    } catch (e) {
      _logger.warning('[${AppConfig.currentUserLogin}] Failed to get page metadata', e);
      return {};
    }
  }

 Future<void> executeAction(Map<String, dynamic> action) async {
  if (!isInitialized) {
    throw Exception('Browser not initialized');
  }

  if (!_validateAction(action)) {
    throw Exception('Invalid action structure: ${action.toString()}');
  }

  try {
    final actionName = action['action_name'] as String?;
    if (actionName == null) {
      throw Exception('Action name is missing');
    }

    _logger.info('[${AppConfig.currentUserLogin}] Executing action: $actionName');
    
    switch (actionName) {
      case 'navigate':
        final params = action['params'] as Map<String, dynamic>?;
        final url = params?['url'] as String?;
        if (url == null || url.isEmpty) {
          throw Exception('URL is missing for navigate action');
        }
        await _page!.goto(url, wait: p.Until.networkIdle);
        _navigationHistory.add(url);
        // Add delay after navigation to ensure page loads
        await Future.delayed(const Duration(seconds: 2));
        break;

      case 'wait':
        final params = action['params'] as Map<String, dynamic>?;
        final timeout = params?['timeout'] as int? ?? 1000;
        await Future.delayed(Duration(milliseconds: timeout));
        break;

      case 'click_element':
        final params = action['params'] as Map<String, dynamic>?;
        final selector = params?['selector'] as String?;
        if (selector == null || selector.isEmpty) {
          throw Exception('Selector is missing for click_element action');
        }
        await _page!.waitForSelector(selector);
        await _page!.click(selector);
        break;

      case 'input_text':
        final params = action['params'] as Map<String, dynamic>?;
        final selector = params?['selector'] as String?;
        final text = params?['text'] as String?;
        if (selector == null || selector.isEmpty) {
          throw Exception('Selector is missing for input_text action');
        }
        if (text == null) {
          throw Exception('Text is missing for input_text action');
        }
        await _page!.waitForSelector(selector);
        await _page!.type(selector, text);
        break;

      case 'scroll':
        final params = action['params'] as Map<String, dynamic>?;
        final x = params?['x'] as int? ?? 0;
        final y = params?['y'] as int? ?? 0;
        await _page!.evaluate('''
          window.scrollTo({
            top: $y,
            left: $x,
            behavior: 'smooth'
          })
        ''');
        await Future.delayed(const Duration(milliseconds: 500));
        break;

      case 'wait_for_selector':
        final params = action['params'] as Map<String, dynamic>?;
        final selector = params?['selector'] as String?;
        if (selector == null || selector.isEmpty) {
          throw Exception('Selector is missing for wait_for_selector action');
        }
        await _page!.waitForSelector(selector);
        break;

      case 'wait_for_navigation':
        await _page!.waitForNavigation(wait: p.Until.networkIdle);
        break;

      default:
        _logger.warning('[${AppConfig.currentUserLogin}] Unknown action: $actionName');
        throw Exception('Unknown action: $actionName');
    }
  } catch (e, stackTrace) {
    _logger.severe('[${AppConfig.currentUserLogin}] Failed to execute action', e, stackTrace);
    rethrow;
  }
}

bool _validateAction(Map<String, dynamic> action) {
  if (!action.containsKey('action_name')) {
    _logger.warning('Action missing action_name');
    return false;
  }

  final actionName = action['action_name'] as String?;
  if (actionName == null || actionName.isEmpty) {
    _logger.warning('Invalid action_name');
    return false;
  }

  final params = action['params'] as Map<String, dynamic>?;
  if (params == null) {
    _logger.warning('Action missing params');
    return false;
  }

  switch (actionName) {
    case 'navigate':
      return params.containsKey('url') && params['url'] != null;
    case 'wait':
      return params.containsKey('timeout');
    case 'click_element':
    case 'wait_for_selector':
      return params.containsKey('selector') && params['selector'] != null;
    case 'input_text':
      return params.containsKey('selector') && 
             params.containsKey('text') && 
             params['selector'] != null && 
             params['text'] != null;
    case 'scroll':
      return true; // x and y are optional with defaults
    case 'wait_for_navigation':
      return true; // no required params
    default:
      _logger.warning('Unknown action type: $actionName');
      return false;
  }
}
  Future<void> dispose() async {
    try {
      await _browser?.close();
      _browser = null;
      _page = null;
      _logger.info('[${AppConfig.currentUserLogin}] Browser disposed successfully');
    } catch (e) {
      _logger.severe('[${AppConfig.currentUserLogin}] Failed to dispose browser', e);
      rethrow;
    }
  }
}

import 'dart:math';

import 'package:alfred/core/browser.dart';
import 'package:alfred/models/visual_elements.dart';
import 'package:logging/logging.dart';

class EnhancedBrowser extends Browser {
  final _logger = Logger('EnhancedBrowser');
  
  Future<List<VisualElement>> getVisibleElements() async {
    if (_page == null) return [];

    try {
      final result = await _page!.evaluate('''
        () => {
          function isElementVisible(element) {
            const style = window.getComputedStyle(element);
            return style.display !== 'none' && 
                   style.visibility !== 'hidden' && 
                   style.opacity !== '0' &&
                   element.offsetWidth > 0 &&
                   element.offsetHeight > 0;
          }

          function isClickable(element) {
            const clickableTags = ['A', 'BUTTON', 'INPUT', 'SELECT'];
            const style = window.getComputedStyle(element);
            return clickableTags.includes(element.tagName) ||
                   style.cursor === 'pointer' ||
                   element.onclick != null ||
                   element.getAttribute('role') === 'button';
          }

          function getSelector(element) {
            if (element.id) return '#' + element.id;
            if (element.className) {
              const classes = Array.from(element.classList).join('.');
              return element.tagName.toLowerCase() + '.' + classes;
            }
            return element.tagName.toLowerCase();
          }

          const elements = Array.from(document.querySelectorAll('*'));
          return elements
            .filter(isElementVisible)
            .map(el => {
              const rect = el.getBoundingClientRect();
              return {
                selector: getSelector(el),
                text: el.textContent || '',
                boundingBox: {
                  x: rect.x,
                  y: rect.y,
                  width: rect.width,
                  height: rect.height
                },
                isVisible: true,
                isClickable: isClickable(el),
                attributes: Object.fromEntries(
                  Array.from(el.attributes).map(attr => [attr.name, attr.value])
                )
              };
            });
        }
      ''');

      return (result as List).map((e) => VisualElement(
        selector: e['selector'],
        text: e['text'],
        boundingBox: BoundingBox(
          x: e['boundingBox']['x'],
          y: e['boundingBox']['y'],
          width: e['boundingBox']['width'],
          height: e['boundingBox']['height'],
        ),
        isVisible: e['isVisible'],
        isClickable: e['isClickable'],
        attributes: Map<String, String>.from(e['attributes']),
      )).toList();
    } catch (e) {
      _logger.severe('Failed to get visible elements', e);
      return [];
    }
  }

  Future<bool> clickElementByVisualLocation(double x, double y) async {
    try {
      await _page!.mouse.move(x, y);
      await _page!.mouse.down();
      await _page!.mouse.up();
      return true;
    } catch (e) {
      _logger.warning('Failed to click at ($x, $y)', e);
      return false;
    }
  }

  Future<bool> smoothScroll(double targetY, {Duration? duration}) async {
    try {
      await _page!.evaluate('''
        (targetY, duration) => {
          return new Promise((resolve) => {
            const startY = window.scrollY;
            const distance = targetY - startY;
            const startTime = performance.now();
            
            function step() {
              const currentTime = performance.now();
              const elapsed = currentTime - startTime;
              
              if (elapsed >= duration) {
                window.scrollTo(0, targetY);
                resolve(true);
                return;
              }
              
              const progress = elapsed / duration;
              const easeInOutCubic = progress < 0.5
                ? 4 * progress * progress * progress
                : 1 - Math.pow(-2 * progress + 2, 3) / 2;
                
              window.scrollTo(0, startY + (distance * easeInOutCubic));
              requestAnimationFrame(step);
            }
            
            requestAnimationFrame(step);
          });
        }
      ''', args: [targetY, duration?.inMilliseconds ?? 1000]);
      return true;
    } catch (e) {
      _logger.warning('Failed to smooth scroll', e);
      return false;
    }
  }
}

// lib/core/retry_strategy.dart
class RetryStrategy {
  final int maxAttempts;
  final Duration initialDelay;
  final double backoffFactor;
  final Duration maxDelay;

  RetryStrategy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffFactor = 2.0,
    this.maxDelay = const Duration(seconds: 10),
  });

  Future<T> execute<T>(Future<T> Function() action) async {
    int attempts = 0;
    Duration currentDelay = initialDelay;
    
    while (true) {
      try {
        attempts++;
        return await action();
      } catch (e) {
        if (attempts >= maxAttempts) rethrow;
        
        await Future.delayed(currentDelay);
        currentDelay = Duration(
          milliseconds: min(
            (currentDelay.inMilliseconds * backoffFactor).round(),
            maxDelay.inMilliseconds,
          ),
        );
      }
    }
  }
}

// lib/agents/visual_agent.dart

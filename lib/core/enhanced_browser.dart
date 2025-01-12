import 'package:alfred/config/app_config.dart';
import 'package:alfred/core/browser.dart';
import 'package:alfred/models/visual_elements.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:puppeteer/puppeteer.dart' as p;
import 'dart:math' show Point;  // Add this import for Point class

class EnhancedBrowser extends Browser {
  final _logger = Logger('EnhancedBrowser');

  // Protected method to access the page
 // Access the page through the parent's protected getter

  p.Page? get _currentPage => page;

  Future<List<VisualElement>> getVisibleElements() async {
    final currentPage = _currentPage;
    if (currentPage == null) return [];

    try {
      final result = await currentPage.evaluate('''
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

     if (result == null) return [];

      return (result as List).map((e) => VisualElement(
        selector: e['selector'] as String? ?? '',
        text: e['text'] as String? ?? '',
        boundingBox: BoundingBox(
          x: (e['boundingBox']['x'] as num?)?.toDouble() ?? 0.0,
          y: (e['boundingBox']['y'] as num?)?.toDouble() ?? 0.0,
          width: (e['boundingBox']['width'] as num?)?.toDouble() ?? 0.0,
          height: (e['boundingBox']['height'] as num?)?.toDouble() ?? 0.0,
        ),
        isVisible: e['isVisible'] as bool? ?? true,
        isClickable: e['isClickable'] as bool? ?? false,
        attributes: Map<String, String>.from(e['attributes'] as Map? ?? {}),
      )).toList();
    } catch (e, stackTrace) {
      _logger.severe('[${AppConfig.currentUserLogin}] Failed to get visible elements', e, stackTrace);
      return [];
    }
  }

  Future<bool> clickElementByVisualLocation(double x, double y) async {
    final page = _currentPage;
    if (page == null) return false;
    
    try {
       final position = Point(x, y);
      
      // Move to position using Point object
      await _currentPage?.mouse.move(position);
      await _currentPage?.mouse.down();
      return true;
    } catch (e, stackTrace) {
      _logger.warning('[${AppConfig.currentUserLogin}] Failed to click at ($x, $y)', e, stackTrace);
      return false;
    }
  }

  Future<bool> smoothScroll(double targetY, {Duration? duration}) async {
    final page = _currentPage;
    if (page == null) return false;
    
    try {
      await page.evaluate('''
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
    } catch (e, stackTrace) {
      _logger.warning('[${AppConfig.currentUserLogin}] Failed to smooth scroll', e, stackTrace);
      return false;
    }
  }
}
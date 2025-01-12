import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:logging/logging.dart';
import 'package:alfred/models/browser_state.dart';

class GeminiService {
  final GenerativeModel model;
  final _logger = Logger('GeminiService');
  
  GeminiService(String apiKey): 
    model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      safetySettings: [
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
      ],
    );

  Future<Map<String, dynamic>> planInitialStrategy(String task) async {
    try {
      final prompt = '''
      Task: $task

      You are an autonomous web browser agent. Given this high-level task, plan the initial strategy.
      Consider:
      1. What websites would be best to gather this information?
      2. What search queries would be most effective?
      3. What information should we look for?

      Respond with a JSON object containing:
      {
        "strategy": {
          "initial_site": "URL of the first site to visit (e.g., google.com, wikipedia.org)",
          "search_query": "The search query to use if needed",
          "information_targets": ["list", "of", "specific", "information", "to", "look", "for"],
          "reasoning": "Explanation of why this strategy was chosen"
        },
        "actions": [
          {
            "action_name": "navigate|input_text|click_element|etc",
            "params": {
              // action-specific parameters
            }
          }
        ]
      }
      ''';

      final chat = model.startChat();
      final content = Content.text(prompt);
      
      String fullResponse = '';
      await for (final response in chat.sendMessageStream(content)) {
        final text = response.text;
        if (text != null) {
          fullResponse += text;
        }
      }

      final parsedResponse = _parseResponse(fullResponse);
      
      // Ensure the strategy has all required fields with defaults if missing
      if (!parsedResponse.containsKey('strategy')) {
        parsedResponse['strategy'] = {
          'initial_site': 'https://www.google.com',
          'search_query': task,
          'information_targets': [task],
          'reasoning': 'Default strategy: Search Google for the given task'
        };
      } else {
        final strategy = parsedResponse['strategy'] as Map<String, dynamic>;
        strategy['initial_site'] ??= 'https://www.google.com';
        strategy['search_query'] ??= task;
        strategy['information_targets'] ??= [task];
        strategy['reasoning'] ??= 'Default strategy: Search Google for the given task';
      }

      if (!parsedResponse.containsKey('actions')) {
        parsedResponse['actions'] = [
          {
            'action_name': 'navigate',
            'params': {
              'url': parsedResponse['strategy']['initial_site']
            }
          }
        ];
      }

      return parsedResponse;
    } catch (e, stackTrace) {
      _logger.severe('Error in planInitialStrategy', e, stackTrace);
      // Return a default strategy if something goes wrong
      return {
        'strategy': {
          'initial_site': 'https://www.google.com',
          'search_query': task,
          'information_targets': [task],
          'reasoning': 'Default strategy: Search Google for the given task'
        },
        'actions': [
          {
            'action_name': 'navigate',
            'params': {
              'url': 'https://www.google.com'
            }
          }
        ]
      };
    }
  }

  Future<Map<String, dynamic>> analyzeAndPlan({
    required String task,
    required BrowserState state,
    required List<String> memory,
    required Map<String, dynamic> strategy,
  }) async {
    try {
      final prompt = _constructPrompt(task, state, memory, strategy);
      _logger.fine('Sending prompt to Gemini: $prompt');

      final chat = model.startChat();
      final parts = <Part>[TextPart(prompt)];
      
      if (state.screenshot != null) {
        parts.add(DataPart('image/png', state.screenshot!));
      }

      final content = Content.multi(parts);

      String fullResponse = '';
      await for (final response in chat.sendMessageStream(content)) {
        final text = response.text;
        if (text != null) {
          fullResponse += text;
          _logger.fine('Received partial response: $text');
        }
      }

      _logger.fine('Received full response from Gemini: $fullResponse');
      return _parseAnalysisResponse(fullResponse);
    } catch (e, stackTrace) {
      _logger.severe('Error in analyzeAndPlan', e, stackTrace);
      return _getDefaultAnalysisResponse();
    }
  }

  String _constructPrompt(String task, BrowserState state, List<String> memory, Map<String, dynamic> strategy) {
    final strategyMap = strategy['strategy'] as Map<String, dynamic>;
    final informationTargets = strategyMap['information_targets'] as List? ?? [task];
    
    return '''
    Task: $task

    Original Strategy:
    ${json.encode(strategy)}

    Current Browser State:
    - URL: ${state.currentUrl}
    - Title: ${state.pageTitle}
    - Elements Count: ${state.elements.length}
    - Is Loading: ${state.isLoading}
    
    Navigation History:
    ${state.navigationHistory.join('\n')}
    
    Previous Actions Memory:
    ${memory.join('\n')}

    Information Targets Remaining:
    ${informationTargets.join('\n')}


    

    Please analyze the current state and plan the next actions.
    Consider:
    1. Have we found the information we're looking for?
    2. Should we explore different sources?
    3. Do we need to refine our search?

    Respond with a JSON object containing:
    {
      "current_state": {
        "evaluation": "Success|Failed|Unknown - Analysis of current state",
        "memory": "What to remember for future steps",
        "next_goal": "What needs to be done next",
        "information_found": ["list", "of", "information", "found"],
        "remaining_targets": ["list", "of", "remaining", "information", "to", "find"]
      },
      "actions": [
        {
          "action_name": "click_element|input_text|scroll|wait|navigate",
          "params": {
            // action-specific parameters
          }
        }
      ],
      "done": boolean,
      "summary": "Summary of information found so far"
    }

    
    ''';
  }

  Map<String, dynamic> _parseResponse(String response) {
    try {
      final jsonMatch = RegExp(r'{[\s\S]*}').firstMatch(response);
      if (jsonMatch == null) {
        throw FormatException('No JSON found in response');
      }

      final jsonStr = jsonMatch.group(0);
      return json.decode(jsonStr!) as Map<String, dynamic>;
    } catch (e) {
      _logger.warning('Error parsing Gemini response', e);
      return {
        'strategy': {
          'initial_site': 'https://www.google.com',
          'search_query': '',
          'information_targets': [],
          'reasoning': 'Default strategy due to parsing error'
        },
        'actions': []
      };
    }
  }

  Map<String, dynamic> _parseAnalysisResponse(String response) {
    try {
      final jsonMatch = RegExp(r'{[\s\S]*}').firstMatch(response);
      if (jsonMatch == null) {
        return _getDefaultAnalysisResponse();
      }

      final jsonStr = jsonMatch.group(0);
      final parsed = json.decode(jsonStr!) as Map<String, dynamic>;
      
      // Ensure all required fields exist
      return {
        'current_state': {
          'evaluation': parsed['current_state']?['evaluation'] ?? 'Unknown',
          'memory': parsed['current_state']?['memory'] ?? 'No memory recorded',
          'next_goal': parsed['current_state']?['next_goal'] ?? 'Continue exploration',
          'information_found': parsed['current_state']?['information_found'] ?? [],
          'remaining_targets': parsed['current_state']?['remaining_targets'] ?? []
        },
        'actions': parsed['actions'] ?? [],
        'done': parsed['done'] ?? false,
        'summary': parsed['summary'] ?? 'No summary available'
      };
    } catch (e) {
      _logger.warning('Error parsing analysis response', e);
      return _getDefaultAnalysisResponse();
    }
  }

  Map<String, dynamic> _getDefaultAnalysisResponse() {
    return {
      'current_state': {
        'evaluation': 'Failed - Error parsing response',
        'memory': 'Error occurred during analysis',
        'next_goal': 'Retry current action',
        'information_found': [],
        'remaining_targets': []
      },
      'actions': [],
      'done': false,
      'summary': 'Error occurred during analysis'
    };
  }
}
import 'dart:async';
import 'package:alfred/core/enhanced_browser.dart';
import 'package:logging/logging.dart';
import 'package:alfred/core/agent.dart' as core;
import 'package:alfred/models/visual_agent_models.dart';
import 'package:alfred/core/browser.dart';
import 'package:alfred/models/browser_state.dart';
import 'package:alfred/services/gemini_services.dart';

class VisualAgent extends core.Agent {
  final _retryStrategy = RetryStrategy();
  bool _shouldStop = false;
  final _stopController = StreamController<void>();
  late final Map<String, dynamic> _strategy;
  
  late final EnhancedBrowser _browser;
  late final GeminiService _gemini;
  final _logger = Logger('VisualAgent');
  
  final _stateController = StreamController<VisualAgentState>.broadcast();
  Stream<VisualAgentState> get stateStream => _stateController.stream;

  Stream<void> get onStop => _stopController.stream;

  VisualAgent({
    required String task,
    required String geminiApiKey,
    required BrowserConfig browserConfig,
    int maxSteps = 25,
  }) : super(
    task: task,
    geminiApiKey: geminiApiKey,
    browserConfig: browserConfig,
    maxSteps: maxSteps,
  );

  @override
  Future<void> initialize() async {
    _browser = EnhancedBrowser();
    await _browser.initialize(browserConfig);
    _gemini = GeminiService(geminiApiKey);
    
    _strategy = await _gemini.planInitialStrategy(task);
    _logger.info('Initial strategy planned: ${_strategy.toString()}');
  }

  void stop() {
    _shouldStop = true;
    _stopController.add(null);
  }

  @override
  Future<core.AgentResult> run() async {
    try {
      _shouldStop = false;
      _stateController.add(VisualAgentState(
        status: 'Starting task: $task',
        currentStep: 0,
        maxSteps: maxSteps,
      ));

      int steps = 0;
      String summary = '';
      List<String> informationFound = [];
      List<String> stepMemory = [];

      while (steps < maxSteps && !_shouldStop) {
        steps++;
        
        try {
          final result = await _retryStrategy.execute(() async {
            final currentState = await _browser.getCurrentState();
            final visibleElements = await _browser.getVisibleElements();

            final stateWithVisual = {
              ...currentState.toJson(),
              'visibleElements': visibleElements.map((e) => e.toJson()).toList(),
            };

            final analysis = await _gemini.analyzeAndPlan(
              task: task,
              state: BrowserState.fromJson(stateWithVisual),
              memory: stepMemory,
              strategy: _strategy,
            );

            final currentStateAnalysis = analysis['current_state'] as Map<String, dynamic>;
            final actions = analysis['actions'] as List;
            final isDone = analysis['done'] as bool;

            final newInfo = currentStateAnalysis['information_found'] as List<dynamic>;
            informationFound.addAll(newInfo.map((e) => e.toString()));

            final memoryEntry = currentStateAnalysis['memory']?.toString() ?? '';
            if (memoryEntry.isNotEmpty) {
              stepMemory.add(memoryEntry);
            }

            _stateController.add(VisualAgentState(
              status: 'Step $steps: ${currentStateAnalysis['next_goal']}',
              currentStep: steps,
              maxSteps: maxSteps,
              currentStateEvaluation: currentStateAnalysis['evaluation'] as String,
            ));

            if (isDone) {
              summary = analysis['summary'] as String;
              return true;
            }

            for (final action in actions) {
              if (_shouldStop) break;
              
              final actionMap = action as Map<String, dynamic>;
              if (actionMap['action_name'] == 'click_element' && 
                  actionMap['params']['coordinates'] != null) {
                final coords = actionMap['params']['coordinates'] as Map<String, dynamic>;
                await _browser.clickElementByVisualLocation(
                  coords['x'] as double,
                  coords['y'] as double,
                );
              } else if (actionMap['action_name'] == 'scroll') {
                await _browser.smoothScroll(
                  actionMap['params']['y'] as double,
                );
              } else {
                await _browser.executeAction(actionMap);
              }
              
              await Future.delayed(const Duration(milliseconds: 500));
            }

            return false;
          });

          if (result) break;
        } catch (e) {
          _logger.warning('Step $steps failed, retrying...', e);
          continue;
        }
      }

      return core.AgentResult(
        summary: _shouldStop ? 'Task stopped by user' : summary,
        informationFound: informationFound,
        finalState: await _browser.getCurrentState(),
      );
    } catch (e, stackTrace) {
      _logger.severe('Error during agent execution', e, stackTrace);
      return core.AgentResult(
        summary: 'Failed to complete task',
        error: e.toString(),
      );
    }
  }

  @override
  Future<void> dispose() async {
    await _browser.dispose();
    await _stopController.close();
    await _stateController.close();
  }
}

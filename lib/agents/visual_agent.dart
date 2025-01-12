import 'dart:async';
import 'package:meta/meta.dart';
import 'package:alfred/core/enhanced_browser.dart';
import 'package:logging/logging.dart';
import 'package:alfred/core/agent.dart' as core;
import 'package:alfred/models/visual_agent_models.dart';
import 'package:alfred/core/browser.dart';
import 'package:alfred/models/browser_state.dart';
import 'package:alfred/services/gemini_services.dart';
import 'package:alfred/config/app_config.dart';

@immutable
class VisualAgentState extends core.AgentState {
  final String status;
  final int currentStep;
  final int maxSteps;
  final String? currentStateEvaluation;
  final DateTime timestamp;
  final String userLogin;
  final Map<String, dynamic>? metadata;

  const VisualAgentState({
    required this.status,
    required this.currentStep,
    required this.maxSteps,
    this.currentStateEvaluation,
    Map<String, dynamic>? metadata,
  }) : timestamp = AppConfig.currentUtcTime,
       userLogin = AppConfig.currentUserLogin,
       metadata = metadata,
       super(
         status: status,
         currentStep: currentStep,
         maxSteps: maxSteps,
         timestamp: AppConfig.currentUtcTime,
         userLogin: AppConfig.currentUserLogin,
       );

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'currentStateEvaluation': currentStateEvaluation,
    'metadata': metadata,
  };

  @override
  String toString() => 'VisualAgentState(status: $status, step: $currentStep/$maxSteps)';
}

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
    final logger = Logger('RetryStrategy');

    while (true) {
      try {
        attempts++;
        return await action();
      } catch (e, stackTrace) {
        if (attempts >= maxAttempts) {
          logger.severe(
            '[${AppConfig.currentUserLogin}] Failed after $attempts attempts',
            e,
            stackTrace
          );
          rethrow;
        }

        logger.warning(
          '[${AppConfig.currentUserLogin}] Attempt $attempts failed, retrying in ${currentDelay.inSeconds}s',
          e,
          stackTrace
        );

        await Future.delayed(currentDelay);
        currentDelay = Duration(
          milliseconds: (currentDelay.inMilliseconds * backoffFactor)
            .clamp(0, maxDelay.inMilliseconds)
            .toInt(),
        );
      }
    }
  }
}

class VisualAgent extends core.Agent {
  final _retryStrategy = RetryStrategy();
  bool _shouldStop = false;
  final _stopController = StreamController<void>();
  late final Map<String, dynamic> _strategy;
  
  late final EnhancedBrowser _browser;
  late final GeminiService _gemini;
  final _logger = Logger('VisualAgent');
  
  final String task;
  final String geminiApiKey;
  final BrowserConfig browserConfig;
  final int maxSteps;
  
  final _stateController = StreamController<core.AgentState>.broadcast();
  
  @override
  Stream<core.AgentState> get stateStream => _stateController.stream;

  Stream<void> get onStop => _stopController.stream;

  VisualAgent({
    required this.task,
    required this.geminiApiKey,
    required this.browserConfig,
    this.maxSteps = 25,
  }) : super(task: task);

  @override
  Future<void> initialize() async {
    try {
      _logger.info('[${AppConfig.currentUserLogin}] Initializing VisualAgent for task: $task');
      
      _browser = EnhancedBrowser();
      await _browser.initialize(browserConfig);
      
      _gemini = GeminiService(geminiApiKey);
      _strategy = await _gemini.planInitialStrategy(task);
      
      _logger.info('[${AppConfig.currentUserLogin}] Initial strategy planned: ${_strategy.toString()}');
    } catch (e, stackTrace) {
      _logger.severe('[${AppConfig.currentUserLogin}] Failed to initialize VisualAgent', e, stackTrace);
      rethrow;
    }
  }

  @override
  void stop() {
    _shouldStop = true;
    _stopController.add(null);
    _logger.info('[${AppConfig.currentUserLogin}] Agent stop requested');
  }

  @override
  Future<core.AgentResult> run() async {
    try {
      _shouldStop = false;
      _stateController.add(VisualAgentState(
        status: 'Starting task: $task',
        currentStep: 0,
        maxSteps: maxSteps,
        metadata: {'startTime': AppConfig.currentUtcTime.toIso8601String()},
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
              'timestamp': AppConfig.currentUtcTime.toIso8601String(),
              'userLogin': AppConfig.currentUserLogin,
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
              metadata: {
                'currentUrl': currentState.currentUrl,
                'pageTitle': currentState.pageTitle,
                'memoryCount': stepMemory.length,
                'informationFoundCount': informationFound.length,
              },
            ));

            if (isDone) {
              summary = analysis['summary'] as String;
              return true;
            }

            for (final action in actions) {
              if (_shouldStop) break;
              
              final actionMap = action as Map<String, dynamic>;
              await _browser.executeAction(actionMap);
              await Future.delayed(const Duration(milliseconds: 500));
            }

            return false;
          });

          if (result || _shouldStop) break;
        } catch (e, stackTrace) {
          _logger.warning(
            '[${AppConfig.currentUserLogin}] Step $steps failed, retrying...',
            e,
            stackTrace
          );
          
          _stateController.add(VisualAgentState(
            status: 'Error in step $steps: ${e.toString()}',
            currentStep: steps,
            maxSteps: maxSteps,
            metadata: {'error': e.toString(), 'stackTrace': stackTrace.toString()},
          ));
          
          continue;
        }
      }

      final endTime = AppConfig.currentUtcTime;
      final additionalData = {
        'steps_taken': steps,
        'max_steps': maxSteps,
        'completed': !_shouldStop,
        'start_time': AppConfig.currentUtcTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'duration_seconds': endTime.difference(AppConfig.currentUtcTime).inSeconds,
        'memory_entries': stepMemory.length,
        'user': AppConfig.currentUserLogin,
      };

      _stateController.add(VisualAgentState(
        status: 'Task completed',
        currentStep: steps,
        maxSteps: maxSteps,
        metadata: additionalData,
      ));

      return core.AgentResult(
        summary: _shouldStop ? 'Task stopped by user' : summary,
        informationFound: informationFound,
        finalState: await _browser.getCurrentState(),
        additionalData: additionalData,
      );
    } catch (e, stackTrace) {
      final errorData = {
        'timestamp': AppConfig.currentUtcTime.toIso8601String(),
        'user': AppConfig.currentUserLogin,
        'error': e.toString(),
        'stack_trace': stackTrace.toString(),
      };

      _logger.severe(
        '[${AppConfig.currentUserLogin}] Error during agent execution',
        e,
        stackTrace
      );

      return core.AgentResult(
        summary: 'Failed to complete task',
        error: e.toString(),
        additionalData: errorData,
      );
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _browser.dispose();
      await _stopController.close();
      await _stateController.close();
      _logger.info('[${AppConfig.currentUserLogin}] Agent disposed successfully');
    } catch (e, stackTrace) {
      _logger.severe(
        '[${AppConfig.currentUserLogin}] Error during agent disposal',
        e,
        stackTrace
      );
      rethrow;
    }
  }
}
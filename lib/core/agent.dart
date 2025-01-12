import 'dart:async';
import 'package:logging/logging.dart';
import '../core/browser.dart';
import '../models/browser_state.dart';
import '../services/gemini_services.dart';

class Agent {
  final String task;
  final String geminiApiKey;
  final BrowserConfig browserConfig;
  final int maxSteps;
  
  late final Browser _browser;
  late final GeminiService _gemini;
  final _logger = Logger('Agent');
  
  final List<String> _memory = [];
  late Map<String, dynamic> _strategy;
  final _stateController = StreamController<AgentState>.broadcast();
  
  Stream<AgentState> get stateStream => _stateController.stream;
  
  Agent({
    required this.task,
    required this.geminiApiKey,
    required this.browserConfig,
    this.maxSteps = 25,
  });

  Future<void> initialize() async {
    _browser = Browser();
    await _browser.initialize(browserConfig);
    _gemini = GeminiService(geminiApiKey);
    
    // Plan initial strategy
    _strategy = await _gemini.planInitialStrategy(task);
    _logger.info('Initial strategy planned: ${_strategy.toString()}');
  }

  Future<AgentResult> run() async {
    try {
      _stateController.add(AgentState(
        status: 'Starting task: $task',
        currentStep: 0,
        maxSteps: maxSteps,
      ));

      int steps = 0;
      String summary = '';
      List<String> informationFound = [];

      while (steps < maxSteps) {
        steps++;
        _stateController.add(AgentState(
          status: 'Executing step $steps',
          currentStep: steps,
          maxSteps: maxSteps,
        ));

        final currentState = await _browser.getCurrentState();
        
        final analysis = await _gemini.analyzeAndPlan(
          task: task,
          state: currentState,
          memory: _memory,
          strategy: _strategy,
        );

        final currentStateAnalysis = analysis['current_state'] as Map<String, dynamic>;
        final actions = analysis['actions'] as List;
        final isDone = analysis['done'] as bool;
        
        // Update information found
        final newInfo = currentStateAnalysis['information_found'] as List;
        informationFound.addAll(newInfo.cast<String>());
        
        // Add to memory
        _memory.add(currentStateAnalysis['memory'] as String);
        
        // Update status
        _stateController.add(AgentState(
          status: 'Step $steps: ${currentStateAnalysis['next_goal']}',
          currentStep: steps,
          maxSteps: maxSteps,
          currentStateEvaluation: currentStateAnalysis['evaluation'] as String,
        ));

        if (isDone) {
          summary = analysis['summary'] as String;
          break;
        }

        // Execute actions
        for (final action in actions) {
          await _browser.executeAction(action as Map<String, dynamic>);
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      return AgentResult(
        summary: summary,
        informationFound: informationFound,
        finalState: await _browser.getCurrentState(),
      );
    } catch (e, stackTrace) {
      _logger.severe('Error during agent execution', e, stackTrace);
      return AgentResult(
        summary: 'Failed to complete task',
        error: e.toString(),
      );
    }
  }

  Future<void> dispose() async {
    await _browser.dispose();
    await _stateController.close();
  }
}

class AgentState {
  final String status;
  final int currentStep;
  final int maxSteps;
  final String? currentStateEvaluation;

  AgentState({
    required this.status,
    required this.currentStep,
    required this.maxSteps,
    this.currentStateEvaluation,
  });

  @override
  String toString() {
    return '''
    Step: $currentStep/$maxSteps
    Status: $status
    ${currentStateEvaluation != null ? 'Evaluation: $currentStateEvaluation' : ''}
    ''';
  }
}

class AgentResult {
  final String summary;
  final String? error;
  final List<String>? informationFound;
  final BrowserState? finalState;

  AgentResult({
    required this.summary,
    this.error,
    this.informationFound,
    this.finalState,
  });

  @override
  String toString() {
    if (error != null) {
      return 'AgentResult(error: $error)';
    }
    
    return '''
    AgentResult:
    Summary: $summary
    Information Found:
    ${informationFound?.join('\n') ?? 'None'}
    ''';
  }
}
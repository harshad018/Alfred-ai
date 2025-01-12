import 'package:alfred/models/browser_state.dart';

class VisualAgentResult {
  final String summary;
  final String? error;
  final List<String>? informationFound;
  final BrowserState? finalState;

  VisualAgentResult({
    required this.summary,
    this.error,
    this.informationFound,
    this.finalState,
  });

  @override
  String toString() {
    if (error != null) {
      return 'VisualAgentResult(error: $error)';
    }
    return '''
VisualAgentResult:
Summary: $summary
Information Found:
${informationFound?.join('\n') ?? 'None'}
''';
  }
}

class VisualAgentState {
  final String status;
  final int currentStep;
  final int maxSteps;
  final String? currentStateEvaluation;

  VisualAgentState({
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

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
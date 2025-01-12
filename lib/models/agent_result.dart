import 'package:alfred/models/browser_state.dart';

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
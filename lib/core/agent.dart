// In core/agent.dart
import 'package:alfred/models/browser_state.dart';

class AgentState {
  final String status;
  final int currentStep;
  final int maxSteps;
  final DateTime timestamp;
  final String userLogin;

  const AgentState({
    required this.status,
    required this.currentStep,
    required this.maxSteps,
    required this.timestamp,
    required this.userLogin,
  });

  Map<String, dynamic> toJson() => {
    'status': status,
    'currentStep': currentStep,
    'maxSteps': maxSteps,
    'timestamp': timestamp.toIso8601String(),
    'userLogin': userLogin,
  };
}

class AgentResult {
  final String summary;
  final List<String> informationFound;
  final BrowserState? finalState;
  final String? error;
  final Map<String, dynamic>? additionalData;  // Note the name change from metadata

  const AgentResult({
    required this.summary,
    this.informationFound = const [],
    this.finalState,
    this.error,
    this.additionalData,
  });
}
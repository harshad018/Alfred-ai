import 'package:alfred/agents/visual_agent.dart';
import 'package:alfred/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'core/agent.dart';
import 'core/browser.dart';
import 'models/browser_state.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AppConfig with current user and time
  AppConfig.initialize(
    currentUserLogin: 'ASHISHx021',
    currentUtcTime: DateTime.utc(2025, 1, 12, 17, 16, 37),
  );

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autonomous Browser Agent',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const BrowserAgentHome(),
    );
  }
}

class BrowserAgentHome extends StatefulWidget {
  const BrowserAgentHome({super.key});

  @override
  State<BrowserAgentHome> createState() => _BrowserAgentHomeState();
}

class _BrowserAgentHomeState extends State<BrowserAgentHome> {
  final TextEditingController _taskController = TextEditingController();
  bool _isProcessing = false;
  String _result = '';
  List<String> _informationFound = [];
  final Logger _logger = Logger('BrowserAgentHome');

  Future<void> _runAgent() async {
    if (_taskController.text.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _result = '';
      _informationFound = [];
    });

    try {
      final browserConfig = BrowserConfig(
        headless: false,
        arguments: [
          '--no-sandbox',
          '--start-maximized',
          '--disable-notifications',
        ],
        viewportWidth: 1920,
        viewportHeight: 1080,
        deviceScaleFactor: 1.0,
      );

      final agent = VisualAgent( // Changed from Agent to VisualAgent
        task: _taskController.text,
        geminiApiKey: "AIzaSyAz6opsU5WarrGmNUZBr0obeG3GAc_g8qQ",
        browserConfig: browserConfig,
        maxSteps: 25,
      );

      await agent.initialize();
      
      agent.stateStream.listen((state) {
        setState(() {
          _result += '\n${state.toString()}';
        });
      });

      final agentResult = await agent.run();
      
      setState(() {
        _informationFound = agentResult.informationFound; // Remove null check since it's non-nullable
        _result += '\n\nTask Summary:\n${agentResult.summary}';
        
        if (agentResult.error != null) {
          _result += '\n\nErrors encountered:\n${agentResult.error}';
        }
      });

      await agent.dispose();
    } catch (e, stackTrace) {
      _logger.severe('[${AppConfig.currentUserLogin}] Error during agent execution', e, stackTrace);
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autonomous Browser Agent'),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter Your Task',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _taskController,
                      decoration: const InputDecoration(
                        hintText: 'e.g., Find information about Elon Musk',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(16),
                      ),
                      maxLines: 3,
                      enabled: !_isProcessing,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isProcessing ? null : _runAgent,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: _isProcessing
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Processing...',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    )
                  : const Text(
                      'Run Agent',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 16),
            if (_informationFound.isNotEmpty) ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Information Found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: _informationFound.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(fontSize: 16)),
                                Expanded(
                                  child: Text(
                                    _informationFound[index],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Execution Log',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: SelectableText(
                              _result,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// lib/config/logging_config.dart

import 'package:logging/logging.dart';

void setupLogging() {
  Logger.root.level = Level.ALL;
  
  Logger.root.onRecord.listen((record) {
    final time = record.time.toIso8601String();
    final level = record.level.name.padRight(7);
    final loggerName = record.loggerName.padRight(15);
    
    print('$time [$level] $loggerName: ${record.message}');
    
    if (record.error != null) {
      print('Error: ${record.error}');
    }
    
    if (record.stackTrace != null) {
      print('Stack trace:\n${record.stackTrace}');
    }
  });
}
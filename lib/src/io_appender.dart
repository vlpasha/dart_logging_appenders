import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logging_appenders/logging_appenders.dart';
import 'package:logging_appenders/src/internal/dummy_logger.dart';
import 'package:logging_appenders/src/remote/base_remote_appender.dart';

typedef SendCallback = Future<void> Function(String message);

// ignore: unused_element
final _logger = DummyLogger('logging_appenders.logzio_appender');

/// Appender which sends all logs to https://logz.io/
/// Uses
class IoApiAppender extends BaseDioLogSender {
  IoApiAppender({
    LogRecordFormatter? formatter,
    required this.labels,
    required this.onSend,
    this.type = 'flutterlog',
    int? bufferSize,
  }) : super(formatter: formatter, bufferSize: bufferSize);

  final Map<String, String> labels;
  final String type;
  final SendCallback onSend;

  @override
  Future<void> sendLogEventsWithDio(List<LogEntry> entries,
      Map<String, String> userProperties, CancelToken cancelToken) {
    _logger.finest('Sending logs to $type');
    final body = entries
        .map((entry) => {
              '@timestamp': entry.ts.toUtc().toIso8601String(),
              'message': entry.line,
              'user': userProperties,
            }
              ..addAll(labels)
              ..addAll(entry.lineLabels))
        .map((map) => json.encode(map))
        .join('\n');
    return onSend(body).then((val) => null);
  }
}

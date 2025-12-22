import 'package:uuid/uuid.dart';

/// A parameter definition for logging (e.g., Viscosity, Temperature).
class LogParameter {
  /// Creates a new log parameter.
  LogParameter({
    required this.name,
    required this.unit,
  });

  /// Create from JSON map.
  factory LogParameter.fromJson(Map<String, dynamic> json) {
    return LogParameter(
      name: json['name'] as String,
      unit: json['unit'] as String,
    );
  }

  /// Parameter name (e.g., "Viscosity").
  final String name;

  /// Unit of measurement (e.g., "cP").
  final String unit;

  /// Convert to JSON map for storage.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'unit': unit,
    };
  }

  @override
  String toString() => '$name ($unit)';
}

/// A single log entry with timestamp and parameter values.
class LogEntry {
  /// Creates a new log entry.
  LogEntry({
    required this.timestamp,
    required this.values,
  });

  /// Create from JSON map.
  factory LogEntry.fromJson(Map<String, dynamic> json) {
    final valuesMap = json['values'] as Map<String, dynamic>;
    return LogEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      values: valuesMap.map((k, v) => MapEntry(k, (v as num).toDouble())),
    );
  }

  /// When the entry was recorded.
  final DateTime timestamp;

  /// Parameter values keyed by parameter name.
  final Map<String, double> values;

  /// Convert to JSON map for storage.
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'values': values,
    };
  }
}

/// A logging session containing multiple entries.
class LogSession {
  /// Creates a new log session.
  LogSession({
    String? id,
    required this.title,
    DateTime? startTime,
    this.endTime,
    required this.parameters,
    List<LogEntry>? entries,
  })  : id = id ?? const Uuid().v4(),
        startTime = startTime ?? DateTime.now(),
        entries = entries ?? [];

  /// Create from JSON map from Hive storage.
  factory LogSession.fromJson(Map<String, dynamic> json) {
    return LogSession(
      id: json['id'] as String,
      title: json['title'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      parameters: (json['parameters'] as List<dynamic>)
          .map((p) => LogParameter.fromJson(p as Map<String, dynamic>))
          .toList(),
      entries: (json['entries'] as List<dynamic>)
          .map((e) => LogEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Unique identifier for the session.
  final String id;

  /// Session title (e.g., "Reactor 3 Test").
  final String title;

  /// When the session started.
  final DateTime startTime;

  /// When the session ended (null if still active).
  DateTime? endTime;

  /// Parameters being tracked in this session.
  final List<LogParameter> parameters;

  /// Recorded entries.
  final List<LogEntry> entries;

  /// Add a new entry to the session.
  void addEntry(LogEntry entry) {
    entries.add(entry);
  }

  /// End the session by setting the end time.
  void endSession() {
    endTime = DateTime.now();
  }

  /// Duration of the session.
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Check if the session is active.
  bool get isActive => endTime == null;

  /// Convert to JSON map for Hive storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'parameters': parameters.map((p) => p.toJson()).toList(),
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() =>
      'LogSession(id: $id, title: $title, entries: ${entries.length})';
}

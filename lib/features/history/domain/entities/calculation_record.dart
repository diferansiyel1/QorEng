import 'package:uuid/uuid.dart';

/// Types of engineering modules for categorizing calculations.
enum ModuleType {
  electrical('Electrical', '⚡'),
  mechanical('Mechanical', '⚙️'),
  chemical('Chemical', '🧪'),
  bioprocess('Bioprocess', '🧬'),
  other('Other', '📐');

  const ModuleType(this.label, this.emoji);

  final String label;
  final String emoji;

  String toJson() => name;

  static ModuleType fromJson(String json) {
    return ModuleType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => ModuleType.other,
    );
  }
}

/// A record of a calculation performed in the app.
///
/// Stored in Hive for offline persistence.
class CalculationRecord {
  /// Creates a new calculation record.
  CalculationRecord({
    String? id,
    required this.title,
    required this.resultValue,
    required this.moduleType,
    DateTime? timestamp,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  /// Create from JSON map from Hive storage.
  factory CalculationRecord.fromJson(Map<String, dynamic> json) {
    return CalculationRecord(
      id: json['id'] as String,
      title: json['title'] as String,
      resultValue: json['resultValue'] as String,
      moduleType: ModuleType.fromJson(json['moduleType'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Unique identifier for the record.
  final String id;

  /// Display title (e.g., "Voltage Drop: 4.2V").
  final String title;

  /// Result value as a formatted string.
  final String resultValue;

  /// Module type for categorization and icon display.
  final ModuleType moduleType;

  /// When the calculation was performed.
  final DateTime timestamp;

  /// Convert to JSON map for Hive storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'resultValue': resultValue,
      'moduleType': moduleType.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'CalculationRecord(id: $id, title: $title, resultValue: $resultValue)';
}

import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:engicore/features/history/domain/entities/calculation_record.dart';

part 'history_repository.g.dart';

/// Repository for managing calculation history persistence.
///
/// Uses Hive for local storage of calculation records.
class HistoryRepository {
  HistoryRepository(this._box);

  final Box<String> _box;

  static const String boxName = 'history_box';

  /// Save a calculation record to history.
  Future<void> saveRecord(CalculationRecord record) async {
    final json = jsonEncode(record.toJson());
    await _box.put(record.id, json);
  }

  /// Get all records sorted by newest first.
  List<CalculationRecord> getAllRecords() {
    final records = <CalculationRecord>[];

    for (final key in _box.keys) {
      final json = _box.get(key);
      if (json != null) {
        try {
          final map = jsonDecode(json) as Map<String, dynamic>;
          records.add(CalculationRecord.fromJson(map));
        } catch (_) {
          // Skip malformed records
        }
      }
    }

    // Sort by newest first
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  /// Delete a single record by ID.
  Future<void> deleteRecord(String id) async {
    await _box.delete(id);
  }

  /// Clear all history records.
  Future<void> clearHistory() async {
    await _box.clear();
  }

  /// Get the number of records.
  int get recordCount => _box.length;
}

/// Provider for the Hive box.
@riverpod
Box<String> historyBox(Ref ref) {
  throw UnimplementedError(
    'historyBox must be overridden with the actual Hive box',
  );
}

/// Provider for the history repository.
@riverpod
HistoryRepository historyRepository(Ref ref) {
  final box = ref.watch(historyBoxProvider);
  return HistoryRepository(box);
}

/// Provider for the list of calculation records.
@riverpod
class HistoryRecords extends _$HistoryRecords {
  @override
  List<CalculationRecord> build() {
    final repo = ref.watch(historyRepositoryProvider);
    return repo.getAllRecords();
  }

  /// Add a new record and refresh the list.
  Future<void> addRecord(CalculationRecord record) async {
    final repo = ref.read(historyRepositoryProvider);
    await repo.saveRecord(record);
    // Use state assignment instead of invalidateSelf to avoid disposal issues
    try {
      state = repo.getAllRecords();
    } catch (_) {
      // Provider may have been disposed during async operation
    }
  }

  /// Delete a record and refresh the list.
  Future<void> deleteRecord(String id) async {
    final repo = ref.read(historyRepositoryProvider);
    await repo.deleteRecord(id);
    try {
      state = repo.getAllRecords();
    } catch (_) {
      // Provider may have been disposed during async operation
    }
  }

  /// Clear all records and refresh the list.
  Future<void> clearAll() async {
    final repo = ref.read(historyRepositoryProvider);
    await repo.clearHistory();
    try {
      state = [];
    } catch (_) {
      // Provider may have been disposed during async operation
    }
  }
}

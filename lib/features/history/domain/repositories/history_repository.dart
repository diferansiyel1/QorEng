import 'dart:convert';
import 'dart:developer' as developer;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:engicore/features/history/domain/entities/calculation_record.dart';

part 'history_repository.g.dart';

/// Result of a repository operation.
sealed class RepositoryResult<T> {
  const RepositoryResult();
}

/// Successful repository operation.
class RepositorySuccess<T> extends RepositoryResult<T> {
  const RepositorySuccess([this.data]);

  final T? data;
}

/// Failed repository operation.
class RepositoryFailure<T> extends RepositoryResult<T> {
  const RepositoryFailure(this.message);

  final String message;
}

/// Repository for managing calculation history persistence.
///
/// Uses encrypted Hive for local storage of calculation records.
class HistoryRepository {
  HistoryRepository(this._box);

  final Box<String> _box;

  static const String boxName = 'history_box';

  /// Save a calculation record to history.
  /// Returns success/failure for UI feedback.
  Future<RepositoryResult<void>> saveRecord(CalculationRecord record) async {
    try {
      final json = jsonEncode(record.toJson());
      await _box.put(record.id, json);
      return const RepositorySuccess();
    } catch (e, s) {
      developer.log(
        'Failed to save calculation record',
        name: 'HistoryRepository',
        error: e,
        stackTrace: s,
      );
      return RepositoryFailure(e.toString());
    }
  }

  /// Get all records sorted by newest first.
  /// Logs and skips corrupted records.
  List<CalculationRecord> getAllRecords() {
    final records = <CalculationRecord>[];
    final corruptedKeys = <dynamic>[];

    for (final key in _box.keys) {
      final json = _box.get(key);
      if (json != null) {
        try {
          final map = jsonDecode(json) as Map<String, dynamic>;
          records.add(CalculationRecord.fromJson(map));
        } catch (e) {
          developer.log(
            'Corrupted record at key $key, skipping',
            name: 'HistoryRepository',
            error: e,
          );
          corruptedKeys.add(key);
        }
      }
    }

    // Log summary of corrupted records for monitoring
    if (corruptedKeys.isNotEmpty) {
      developer.log(
        'Found ${corruptedKeys.length} corrupted records in history',
        name: 'HistoryRepository',
        level: 900,
      );
    }

    // Sort by newest first
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  /// Delete a single record by ID.
  /// Returns success/failure for UI feedback.
  Future<RepositoryResult<void>> deleteRecord(String id) async {
    try {
      await _box.delete(id);
      return const RepositorySuccess();
    } catch (e, s) {
      developer.log(
        'Failed to delete record $id',
        name: 'HistoryRepository',
        error: e,
        stackTrace: s,
      );
      return RepositoryFailure(e.toString());
    }
  }

  /// Clear all history records.
  /// Returns success/failure for UI feedback.
  Future<RepositoryResult<int>> clearHistory() async {
    try {
      final count = _box.length;
      await _box.clear();
      return RepositorySuccess(count);
    } catch (e, s) {
      developer.log(
        'Failed to clear history',
        name: 'HistoryRepository',
        error: e,
        stackTrace: s,
      );
      return RepositoryFailure(e.toString());
    }
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
  Future<bool> addRecord(CalculationRecord record) async {
    final repo = ref.read(historyRepositoryProvider);
    final result = await repo.saveRecord(record);

    switch (result) {
      case RepositorySuccess():
        try {
          state = repo.getAllRecords();
        } catch (_) {
          // Provider may have been disposed during async operation
        }
        return true;
      case RepositoryFailure():
        return false;
    }
  }

  /// Delete a record and refresh the list.
  Future<bool> deleteRecord(String id) async {
    final repo = ref.read(historyRepositoryProvider);
    final result = await repo.deleteRecord(id);

    switch (result) {
      case RepositorySuccess():
        try {
          state = repo.getAllRecords();
        } catch (_) {
          // Provider may have been disposed during async operation
        }
        return true;
      case RepositoryFailure():
        return false;
    }
  }

  /// Clear all records and refresh the list.
  Future<bool> clearAll() async {
    final repo = ref.read(historyRepositoryProvider);
    final result = await repo.clearHistory();

    switch (result) {
      case RepositorySuccess():
        try {
          state = [];
        } catch (_) {
          // Provider may have been disposed during async operation
        }
        return true;
      case RepositoryFailure():
        return false;
    }
  }
}

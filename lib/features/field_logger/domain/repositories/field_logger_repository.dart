import 'dart:convert';
import 'dart:developer' as developer;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:engicore/features/field_logger/domain/entities/log_session.dart';

part 'field_logger_repository.g.dart';

/// Result of a repository operation.
sealed class FieldLoggerResult<T> {
  const FieldLoggerResult();
}

/// Successful repository operation.
class FieldLoggerSuccess<T> extends FieldLoggerResult<T> {
  const FieldLoggerSuccess([this.data]);

  final T? data;
}

/// Failed repository operation.
class FieldLoggerFailure<T> extends FieldLoggerResult<T> {
  const FieldLoggerFailure(this.message);

  final String message;
}

/// Repository for managing field logger session persistence.
///
/// Uses encrypted Hive for local storage of logging sessions.
class FieldLoggerRepository {
  FieldLoggerRepository(this._box);

  final Box<String> _box;

  static const String boxName = 'field_logger_box';

  /// Save a logging session.
  /// Returns success/failure for UI feedback.
  Future<FieldLoggerResult<void>> saveSession(LogSession session) async {
    try {
      final json = jsonEncode(session.toJson());
      await _box.put(session.id, json);
      return const FieldLoggerSuccess();
    } catch (e, s) {
      developer.log(
        'Failed to save logging session',
        name: 'FieldLoggerRepository',
        error: e,
        stackTrace: s,
      );
      return FieldLoggerFailure(e.toString());
    }
  }

  /// Get a session by ID.
  LogSession? getSession(String id) {
    final json = _box.get(id);
    if (json == null) return null;
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return LogSession.fromJson(map);
    } catch (e) {
      developer.log(
        'Corrupted session at key $id',
        name: 'FieldLoggerRepository',
        error: e,
      );
      return null;
    }
  }

  /// Get all sessions sorted by newest first.
  /// Logs and skips corrupted records.
  List<LogSession> getAllSessions() {
    final sessions = <LogSession>[];
    final corruptedKeys = <dynamic>[];

    for (final key in _box.keys) {
      final json = _box.get(key);
      if (json != null) {
        try {
          final map = jsonDecode(json) as Map<String, dynamic>;
          sessions.add(LogSession.fromJson(map));
        } catch (e) {
          developer.log(
            'Corrupted session at key $key, skipping',
            name: 'FieldLoggerRepository',
            error: e,
          );
          corruptedKeys.add(key);
        }
      }
    }

    // Log summary of corrupted records for monitoring
    if (corruptedKeys.isNotEmpty) {
      developer.log(
        'Found ${corruptedKeys.length} corrupted sessions in field logger',
        name: 'FieldLoggerRepository',
        level: 900,
      );
    }

    // Sort by newest first
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions;
  }

  /// Delete a session by ID.
  /// Returns success/failure for UI feedback.
  Future<FieldLoggerResult<void>> deleteSession(String id) async {
    try {
      await _box.delete(id);
      return const FieldLoggerSuccess();
    } catch (e, s) {
      developer.log(
        'Failed to delete session $id',
        name: 'FieldLoggerRepository',
        error: e,
        stackTrace: s,
      );
      return FieldLoggerFailure(e.toString());
    }
  }

  /// Clear all sessions.
  /// Returns success/failure with count for UI feedback.
  Future<FieldLoggerResult<int>> clearAll() async {
    try {
      final count = _box.length;
      await _box.clear();
      return FieldLoggerSuccess(count);
    } catch (e, s) {
      developer.log(
        'Failed to clear sessions',
        name: 'FieldLoggerRepository',
        error: e,
        stackTrace: s,
      );
      return FieldLoggerFailure(e.toString());
    }
  }

  /// Get the number of sessions.
  int get sessionCount => _box.length;
}

/// Provider for the Hive box.
@riverpod
Box<String> fieldLoggerBox(Ref ref) {
  throw UnimplementedError(
    'fieldLoggerBox must be overridden with the actual Hive box',
  );
}

/// Provider for the field logger repository.
@riverpod
FieldLoggerRepository fieldLoggerRepository(Ref ref) {
  final box = ref.watch(fieldLoggerBoxProvider);
  return FieldLoggerRepository(box);
}

/// Provider for the list of log sessions.
@riverpod
class LogSessions extends _$LogSessions {
  @override
  List<LogSession> build() {
    final repo = ref.watch(fieldLoggerRepositoryProvider);
    return repo.getAllSessions();
  }

  /// Add a new session and refresh the list.
  Future<bool> addSession(LogSession session) async {
    final repo = ref.read(fieldLoggerRepositoryProvider);
    final result = await repo.saveSession(session);

    switch (result) {
      case FieldLoggerSuccess():
        try {
          state = repo.getAllSessions();
        } catch (_) {
          // Provider may have been disposed during async operation
        }
        return true;
      case FieldLoggerFailure():
        return false;
    }
  }

  /// Update an existing session.
  Future<bool> updateSession(LogSession session) async {
    final repo = ref.read(fieldLoggerRepositoryProvider);
    final result = await repo.saveSession(session);

    switch (result) {
      case FieldLoggerSuccess():
        try {
          state = repo.getAllSessions();
        } catch (_) {
          // Provider may have been disposed during async operation
        }
        return true;
      case FieldLoggerFailure():
        return false;
    }
  }

  /// Delete a session and refresh the list.
  Future<bool> deleteSession(String id) async {
    final repo = ref.read(fieldLoggerRepositoryProvider);
    final result = await repo.deleteSession(id);

    switch (result) {
      case FieldLoggerSuccess():
        try {
          state = repo.getAllSessions();
        } catch (_) {
          // Provider may have been disposed during async operation
        }
        return true;
      case FieldLoggerFailure():
        return false;
    }
  }
}

/// Provider for the currently active logging session.
/// Keep alive to prevent disposal during navigation.
@Riverpod(keepAlive: true)
class ActiveSession extends _$ActiveSession {
  @override
  LogSession? build() => null;

  /// Set the active session.
  void setSession(LogSession session) {
    state = session;
  }

  /// Add an entry to the active session.
  void addEntry(LogEntry entry) {
    if (state != null) {
      state!.addEntry(entry);
      // Trigger rebuild with new state reference
      state = LogSession(
        id: state!.id,
        title: state!.title,
        startTime: state!.startTime,
        endTime: state!.endTime,
        parameters: state!.parameters,
        entries: List.from(state!.entries),
      );
    }
  }

  /// End the active session.
  Future<bool> endSession() async {
    if (state != null) {
      state!.endSession();
      // Save to repository
      final repo = ref.read(fieldLoggerRepositoryProvider);
      final result = await repo.saveSession(state!);

      switch (result) {
        case FieldLoggerSuccess():
          // Refresh sessions list
          ref.invalidate(logSessionsProvider);
          return true;
        case FieldLoggerFailure():
          return false;
      }
    }
    return true;
  }

  /// Remove the last entry from the active session.
  void removeLastEntry() {
    if (state != null && state!.entries.isNotEmpty) {
      final newEntries = List<LogEntry>.from(state!.entries);
      newEntries.removeLast();
      state = LogSession(
        id: state!.id,
        title: state!.title,
        startTime: state!.startTime,
        endTime: state!.endTime,
        parameters: state!.parameters,
        entries: newEntries,
      );
    }
  }

  /// Clear the active session.
  void clear() {
    state = null;
  }
}

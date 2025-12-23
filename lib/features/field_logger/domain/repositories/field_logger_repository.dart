import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:engicore/features/field_logger/domain/entities/log_session.dart';

part 'field_logger_repository.g.dart';

/// Repository for managing field logger session persistence.
///
/// Uses Hive for local storage of logging sessions.
class FieldLoggerRepository {
  FieldLoggerRepository(this._box);

  final Box<String> _box;

  static const String boxName = 'field_logger_box';

  /// Save a logging session.
  Future<void> saveSession(LogSession session) async {
    final json = jsonEncode(session.toJson());
    await _box.put(session.id, json);
  }

  /// Get a session by ID.
  LogSession? getSession(String id) {
    final json = _box.get(id);
    if (json == null) return null;
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return LogSession.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Get all sessions sorted by newest first.
  List<LogSession> getAllSessions() {
    final sessions = <LogSession>[];

    for (final key in _box.keys) {
      final json = _box.get(key);
      if (json != null) {
        try {
          final map = jsonDecode(json) as Map<String, dynamic>;
          sessions.add(LogSession.fromJson(map));
        } catch (_) {
          // Skip malformed records
        }
      }
    }

    // Sort by newest first
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions;
  }

  /// Delete a session by ID.
  Future<void> deleteSession(String id) async {
    await _box.delete(id);
  }

  /// Clear all sessions.
  Future<void> clearAll() async {
    await _box.clear();
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
  Future<void> addSession(LogSession session) async {
    final repo = ref.read(fieldLoggerRepositoryProvider);
    await repo.saveSession(session);
    try {
      state = repo.getAllSessions();
    } catch (_) {
      // Provider may have been disposed during async operation
    }
  }

  /// Update an existing session.
  Future<void> updateSession(LogSession session) async {
    final repo = ref.read(fieldLoggerRepositoryProvider);
    await repo.saveSession(session);
    try {
      state = repo.getAllSessions();
    } catch (_) {
      // Provider may have been disposed during async operation
    }
  }

  /// Delete a session and refresh the list.
  Future<void> deleteSession(String id) async {
    final repo = ref.read(fieldLoggerRepositoryProvider);
    await repo.deleteSession(id);
    try {
      state = repo.getAllSessions();
    } catch (_) {
      // Provider may have been disposed during async operation
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
  Future<void> endSession() async {
    if (state != null) {
      state!.endSession();
      // Save to repository
      final repo = ref.read(fieldLoggerRepositoryProvider);
      await repo.saveSession(state!);
      // Refresh sessions list
      ref.invalidate(logSessionsProvider);
    }
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

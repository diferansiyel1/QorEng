// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field_logger_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the Hive box.

@ProviderFor(fieldLoggerBox)
const fieldLoggerBoxProvider = FieldLoggerBoxProvider._();

/// Provider for the Hive box.

final class FieldLoggerBoxProvider
    extends $FunctionalProvider<Box<String>, Box<String>, Box<String>>
    with $Provider<Box<String>> {
  /// Provider for the Hive box.
  const FieldLoggerBoxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fieldLoggerBoxProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fieldLoggerBoxHash();

  @$internal
  @override
  $ProviderElement<Box<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Box<String> create(Ref ref) {
    return fieldLoggerBox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Box<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Box<String>>(value),
    );
  }
}

String _$fieldLoggerBoxHash() => r'420262965e0bbc0b7971466583bf1311e31628d8';

/// Provider for the field logger repository.

@ProviderFor(fieldLoggerRepository)
const fieldLoggerRepositoryProvider = FieldLoggerRepositoryProvider._();

/// Provider for the field logger repository.

final class FieldLoggerRepositoryProvider
    extends
        $FunctionalProvider<
          FieldLoggerRepository,
          FieldLoggerRepository,
          FieldLoggerRepository
        >
    with $Provider<FieldLoggerRepository> {
  /// Provider for the field logger repository.
  const FieldLoggerRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fieldLoggerRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fieldLoggerRepositoryHash();

  @$internal
  @override
  $ProviderElement<FieldLoggerRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FieldLoggerRepository create(Ref ref) {
    return fieldLoggerRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FieldLoggerRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FieldLoggerRepository>(value),
    );
  }
}

String _$fieldLoggerRepositoryHash() =>
    r'3196af135baf2d66187a9a7238ccbdefe020db0a';

/// Provider for the list of log sessions.

@ProviderFor(LogSessions)
const logSessionsProvider = LogSessionsProvider._();

/// Provider for the list of log sessions.
final class LogSessionsProvider
    extends $NotifierProvider<LogSessions, List<LogSession>> {
  /// Provider for the list of log sessions.
  const LogSessionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logSessionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logSessionsHash();

  @$internal
  @override
  LogSessions create() => LogSessions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<LogSession> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<LogSession>>(value),
    );
  }
}

String _$logSessionsHash() => r'df78f7b505762b4720eb7ed3087590aac488d0f2';

/// Provider for the list of log sessions.

abstract class _$LogSessions extends $Notifier<List<LogSession>> {
  List<LogSession> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<LogSession>, List<LogSession>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<LogSession>, List<LogSession>>,
              List<LogSession>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for the currently active logging session.
/// Keep alive to prevent disposal during navigation.

@ProviderFor(ActiveSession)
const activeSessionProvider = ActiveSessionProvider._();

/// Provider for the currently active logging session.
/// Keep alive to prevent disposal during navigation.
final class ActiveSessionProvider
    extends $NotifierProvider<ActiveSession, LogSession?> {
  /// Provider for the currently active logging session.
  /// Keep alive to prevent disposal during navigation.
  const ActiveSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeSessionHash();

  @$internal
  @override
  ActiveSession create() => ActiveSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LogSession? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LogSession?>(value),
    );
  }
}

String _$activeSessionHash() => r'630ce332d32ef08c3203c1635f36a7e2cf53038e';

/// Provider for the currently active logging session.
/// Keep alive to prevent disposal during navigation.

abstract class _$ActiveSession extends $Notifier<LogSession?> {
  LogSession? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<LogSession?, LogSession?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LogSession?, LogSession?>,
              LogSession?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

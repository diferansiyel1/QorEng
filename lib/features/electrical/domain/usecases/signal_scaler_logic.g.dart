// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signal_scaler_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Signal Scaler Calculator (4-20mA Converter).
///
/// Forward: PV = ((Measured - RawLow) / (RawHigh - RawLow)) * (EngHigh - EngLow) + EngLow
/// Reverse: mA = ((PV - EngLow) / (EngHigh - EngLow)) * (RawHigh - RawLow) + RawLow

@ProviderFor(SignalScalerCalculator)
const signalScalerCalculatorProvider = SignalScalerCalculatorProvider._();

/// Signal Scaler Calculator (4-20mA Converter).
///
/// Forward: PV = ((Measured - RawLow) / (RawHigh - RawLow)) * (EngHigh - EngLow) + EngLow
/// Reverse: mA = ((PV - EngLow) / (EngHigh - EngLow)) * (RawHigh - RawLow) + RawLow
final class SignalScalerCalculatorProvider
    extends $NotifierProvider<SignalScalerCalculator, SignalScalerInput> {
  /// Signal Scaler Calculator (4-20mA Converter).
  ///
  /// Forward: PV = ((Measured - RawLow) / (RawHigh - RawLow)) * (EngHigh - EngLow) + EngLow
  /// Reverse: mA = ((PV - EngLow) / (EngHigh - EngLow)) * (RawHigh - RawLow) + RawLow
  const SignalScalerCalculatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signalScalerCalculatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signalScalerCalculatorHash();

  @$internal
  @override
  SignalScalerCalculator create() => SignalScalerCalculator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignalScalerInput value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignalScalerInput>(value),
    );
  }
}

String _$signalScalerCalculatorHash() =>
    r'1a8c4dbd1f254d20e52ec957360a3d1da4d41ac8';

/// Signal Scaler Calculator (4-20mA Converter).
///
/// Forward: PV = ((Measured - RawLow) / (RawHigh - RawLow)) * (EngHigh - EngLow) + EngLow
/// Reverse: mA = ((PV - EngLow) / (EngHigh - EngLow)) * (RawHigh - RawLow) + RawLow

abstract class _$SignalScalerCalculator extends $Notifier<SignalScalerInput> {
  SignalScalerInput build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SignalScalerInput, SignalScalerInput>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SignalScalerInput, SignalScalerInput>,
              SignalScalerInput,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Computed signal scaling result.

@ProviderFor(signalScalerResult)
const signalScalerResultProvider = SignalScalerResultProvider._();

/// Computed signal scaling result.

final class SignalScalerResultProvider
    extends
        $FunctionalProvider<
          SignalScalerResult?,
          SignalScalerResult?,
          SignalScalerResult?
        >
    with $Provider<SignalScalerResult?> {
  /// Computed signal scaling result.
  const SignalScalerResultProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signalScalerResultProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signalScalerResultHash();

  @$internal
  @override
  $ProviderElement<SignalScalerResult?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SignalScalerResult? create(Ref ref) {
    return signalScalerResult(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignalScalerResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignalScalerResult?>(value),
    );
  }
}

String _$signalScalerResultHash() =>
    r'38effed989548df97d86d48a69e6154a280d3ec3';

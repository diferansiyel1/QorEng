// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vfd_speed_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// VFD Motor Speed Calculator.
///
/// Synchronous Speed: N_s = (120 × f) / P
/// Actual Speed: N = N_s × (1 - slip/100)
/// Where:
/// - f: Frequency (Hz)
/// - P: Number of poles
/// - slip: Slip percentage

@ProviderFor(VfdSpeedCalculator)
const vfdSpeedCalculatorProvider = VfdSpeedCalculatorProvider._();

/// VFD Motor Speed Calculator.
///
/// Synchronous Speed: N_s = (120 × f) / P
/// Actual Speed: N = N_s × (1 - slip/100)
/// Where:
/// - f: Frequency (Hz)
/// - P: Number of poles
/// - slip: Slip percentage
final class VfdSpeedCalculatorProvider
    extends $NotifierProvider<VfdSpeedCalculator, VfdSpeedInput> {
  /// VFD Motor Speed Calculator.
  ///
  /// Synchronous Speed: N_s = (120 × f) / P
  /// Actual Speed: N = N_s × (1 - slip/100)
  /// Where:
  /// - f: Frequency (Hz)
  /// - P: Number of poles
  /// - slip: Slip percentage
  const VfdSpeedCalculatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vfdSpeedCalculatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vfdSpeedCalculatorHash();

  @$internal
  @override
  VfdSpeedCalculator create() => VfdSpeedCalculator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VfdSpeedInput value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VfdSpeedInput>(value),
    );
  }
}

String _$vfdSpeedCalculatorHash() =>
    r'3c3b6717c5bfeee5e69437fa0586a58ca61d7bf4';

/// VFD Motor Speed Calculator.
///
/// Synchronous Speed: N_s = (120 × f) / P
/// Actual Speed: N = N_s × (1 - slip/100)
/// Where:
/// - f: Frequency (Hz)
/// - P: Number of poles
/// - slip: Slip percentage

abstract class _$VfdSpeedCalculator extends $Notifier<VfdSpeedInput> {
  VfdSpeedInput build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<VfdSpeedInput, VfdSpeedInput>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VfdSpeedInput, VfdSpeedInput>,
              VfdSpeedInput,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Computed VFD speed result.

@ProviderFor(vfdSpeedResult)
const vfdSpeedResultProvider = VfdSpeedResultProvider._();

/// Computed VFD speed result.

final class VfdSpeedResultProvider
    extends
        $FunctionalProvider<VfdSpeedResult?, VfdSpeedResult?, VfdSpeedResult?>
    with $Provider<VfdSpeedResult?> {
  /// Computed VFD speed result.
  const VfdSpeedResultProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vfdSpeedResultProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vfdSpeedResultHash();

  @$internal
  @override
  $ProviderElement<VfdSpeedResult?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VfdSpeedResult? create(Ref ref) {
    return vfdSpeedResult(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VfdSpeedResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VfdSpeedResult?>(value),
    );
  }
}

String _$vfdSpeedResultHash() => r'6b6bf469f7e1e9093db9ba5a9bc36ec6f66eaf5a';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tip_speed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Impeller Tip Speed Calculator.
///
/// Formula: V_tip (m/s) = π × D × (N / 60)
/// Where:
/// - D: Impeller Diameter (meters)
/// - N: Agitation Speed (RPM)

@ProviderFor(TipSpeedCalculator)
const tipSpeedCalculatorProvider = TipSpeedCalculatorProvider._();

/// Impeller Tip Speed Calculator.
///
/// Formula: V_tip (m/s) = π × D × (N / 60)
/// Where:
/// - D: Impeller Diameter (meters)
/// - N: Agitation Speed (RPM)
final class TipSpeedCalculatorProvider
    extends $NotifierProvider<TipSpeedCalculator, TipSpeedInput> {
  /// Impeller Tip Speed Calculator.
  ///
  /// Formula: V_tip (m/s) = π × D × (N / 60)
  /// Where:
  /// - D: Impeller Diameter (meters)
  /// - N: Agitation Speed (RPM)
  const TipSpeedCalculatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tipSpeedCalculatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tipSpeedCalculatorHash();

  @$internal
  @override
  TipSpeedCalculator create() => TipSpeedCalculator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TipSpeedInput value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TipSpeedInput>(value),
    );
  }
}

String _$tipSpeedCalculatorHash() =>
    r'60da66146c157b931f9d245fa713b38d2c38578b';

/// Impeller Tip Speed Calculator.
///
/// Formula: V_tip (m/s) = π × D × (N / 60)
/// Where:
/// - D: Impeller Diameter (meters)
/// - N: Agitation Speed (RPM)

abstract class _$TipSpeedCalculator extends $Notifier<TipSpeedInput> {
  TipSpeedInput build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TipSpeedInput, TipSpeedInput>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TipSpeedInput, TipSpeedInput>,
              TipSpeedInput,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Computed tip speed result based on current input.

@ProviderFor(tipSpeedResult)
const tipSpeedResultProvider = TipSpeedResultProvider._();

/// Computed tip speed result based on current input.

final class TipSpeedResultProvider
    extends
        $FunctionalProvider<TipSpeedResult?, TipSpeedResult?, TipSpeedResult?>
    with $Provider<TipSpeedResult?> {
  /// Computed tip speed result based on current input.
  const TipSpeedResultProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tipSpeedResultProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tipSpeedResultHash();

  @$internal
  @override
  $ProviderElement<TipSpeedResult?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TipSpeedResult? create(Ref ref) {
    return tipSpeedResult(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TipSpeedResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TipSpeedResult?>(value),
    );
  }
}

String _$tipSpeedResultHash() => r'532ff75472a95eb51735a8cf6a16e7a7ec635c2e';

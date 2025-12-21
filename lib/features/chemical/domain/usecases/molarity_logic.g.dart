// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'molarity_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Molarity Converter.
///
/// Formula: M (mol/L) = (g/L) / MW (g/mol)

@ProviderFor(MolarityCalculator)
const molarityCalculatorProvider = MolarityCalculatorProvider._();

/// Molarity Converter.
///
/// Formula: M (mol/L) = (g/L) / MW (g/mol)
final class MolarityCalculatorProvider
    extends $NotifierProvider<MolarityCalculator, MolarityInput> {
  /// Molarity Converter.
  ///
  /// Formula: M (mol/L) = (g/L) / MW (g/mol)
  const MolarityCalculatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'molarityCalculatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$molarityCalculatorHash();

  @$internal
  @override
  MolarityCalculator create() => MolarityCalculator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MolarityInput value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MolarityInput>(value),
    );
  }
}

String _$molarityCalculatorHash() =>
    r'd0712bfa92f2785033c8b3ba00e6eac917c7414e';

/// Molarity Converter.
///
/// Formula: M (mol/L) = (g/L) / MW (g/mol)

abstract class _$MolarityCalculator extends $Notifier<MolarityInput> {
  MolarityInput build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<MolarityInput, MolarityInput>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MolarityInput, MolarityInput>,
              MolarityInput,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Computed molarity result.

@ProviderFor(molarityResult)
const molarityResultProvider = MolarityResultProvider._();

/// Computed molarity result.

final class MolarityResultProvider
    extends
        $FunctionalProvider<MolarityResult?, MolarityResult?, MolarityResult?>
    with $Provider<MolarityResult?> {
  /// Computed molarity result.
  const MolarityResultProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'molarityResultProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$molarityResultHash();

  @$internal
  @override
  $ProviderElement<MolarityResult?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MolarityResult? create(Ref ref) {
    return molarityResult(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MolarityResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MolarityResult?>(value),
    );
  }
}

String _$molarityResultHash() => r'1484cd5a27820fccca256091f4378179bce2c8a0';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beer_lambert_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Beer-Lambert Law Calculator.
///
/// A = ε × l × c
/// Where:
/// - A = Absorbance (dimensionless)
/// - ε = Molar absorptivity (L/(mol·cm))
/// - l = Path length (cm)
/// - c = Concentration (mol/L)

@ProviderFor(BeerLambertCalculator)
const beerLambertCalculatorProvider = BeerLambertCalculatorProvider._();

/// Beer-Lambert Law Calculator.
///
/// A = ε × l × c
/// Where:
/// - A = Absorbance (dimensionless)
/// - ε = Molar absorptivity (L/(mol·cm))
/// - l = Path length (cm)
/// - c = Concentration (mol/L)
final class BeerLambertCalculatorProvider
    extends $NotifierProvider<BeerLambertCalculator, BeerLambertInput> {
  /// Beer-Lambert Law Calculator.
  ///
  /// A = ε × l × c
  /// Where:
  /// - A = Absorbance (dimensionless)
  /// - ε = Molar absorptivity (L/(mol·cm))
  /// - l = Path length (cm)
  /// - c = Concentration (mol/L)
  const BeerLambertCalculatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'beerLambertCalculatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$beerLambertCalculatorHash();

  @$internal
  @override
  BeerLambertCalculator create() => BeerLambertCalculator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BeerLambertInput value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BeerLambertInput>(value),
    );
  }
}

String _$beerLambertCalculatorHash() =>
    r'a64e43558aafdd4373cb3b561e89e59c7a18f9b0';

/// Beer-Lambert Law Calculator.
///
/// A = ε × l × c
/// Where:
/// - A = Absorbance (dimensionless)
/// - ε = Molar absorptivity (L/(mol·cm))
/// - l = Path length (cm)
/// - c = Concentration (mol/L)

abstract class _$BeerLambertCalculator extends $Notifier<BeerLambertInput> {
  BeerLambertInput build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<BeerLambertInput, BeerLambertInput>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BeerLambertInput, BeerLambertInput>,
              BeerLambertInput,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Computed Beer-Lambert result.

@ProviderFor(beerLambertResult)
const beerLambertResultProvider = BeerLambertResultProvider._();

/// Computed Beer-Lambert result.

final class BeerLambertResultProvider
    extends
        $FunctionalProvider<
          BeerLambertResult?,
          BeerLambertResult?,
          BeerLambertResult?
        >
    with $Provider<BeerLambertResult?> {
  /// Computed Beer-Lambert result.
  const BeerLambertResultProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'beerLambertResultProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$beerLambertResultHash();

  @$internal
  @override
  $ProviderElement<BeerLambertResult?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BeerLambertResult? create(Ref ref) {
    return beerLambertResult(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BeerLambertResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BeerLambertResult?>(value),
    );
  }
}

String _$beerLambertResultHash() => r'5e46c10c24314ff4f4f47e7ed5e2ec0e4e32619f';

/// Transmittance <-> Absorbance Converter.

@ProviderFor(TransmittanceConverter)
const transmittanceConverterProvider = TransmittanceConverterProvider._();

/// Transmittance <-> Absorbance Converter.
final class TransmittanceConverterProvider
    extends
        $NotifierProvider<
          TransmittanceConverter,
          ({double absorbance, double transmittance})
        > {
  /// Transmittance <-> Absorbance Converter.
  const TransmittanceConverterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transmittanceConverterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transmittanceConverterHash();

  @$internal
  @override
  TransmittanceConverter create() => TransmittanceConverter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    ({double absorbance, double transmittance}) value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<({double absorbance, double transmittance})>(
            value,
          ),
    );
  }
}

String _$transmittanceConverterHash() =>
    r'dbc293a55da0212978c6408b25d53cc1659f7e07';

/// Transmittance <-> Absorbance Converter.

abstract class _$TransmittanceConverter
    extends $Notifier<({double absorbance, double transmittance})> {
  ({double absorbance, double transmittance}) build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              ({double absorbance, double transmittance}),
              ({double absorbance, double transmittance})
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ({double absorbance, double transmittance}),
                ({double absorbance, double transmittance})
              >,
              ({double absorbance, double transmittance}),
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// OD / Cell Density Calculator.

@ProviderFor(OdCellDensityCalculator)
const odCellDensityCalculatorProvider = OdCellDensityCalculatorProvider._();

/// OD / Cell Density Calculator.
final class OdCellDensityCalculatorProvider
    extends $NotifierProvider<OdCellDensityCalculator, OdCellDensityInput> {
  /// OD / Cell Density Calculator.
  const OdCellDensityCalculatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'odCellDensityCalculatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$odCellDensityCalculatorHash();

  @$internal
  @override
  OdCellDensityCalculator create() => OdCellDensityCalculator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OdCellDensityInput value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OdCellDensityInput>(value),
    );
  }
}

String _$odCellDensityCalculatorHash() =>
    r'5cc2fe319477e5f0b8c2803e142e7af4e0014a60';

/// OD / Cell Density Calculator.

abstract class _$OdCellDensityCalculator extends $Notifier<OdCellDensityInput> {
  OdCellDensityInput build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<OdCellDensityInput, OdCellDensityInput>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OdCellDensityInput, OdCellDensityInput>,
              OdCellDensityInput,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Computed OD / Cell Density result.

@ProviderFor(odCellDensityResult)
const odCellDensityResultProvider = OdCellDensityResultProvider._();

/// Computed OD / Cell Density result.

final class OdCellDensityResultProvider
    extends
        $FunctionalProvider<
          OdCellDensityResult?,
          OdCellDensityResult?,
          OdCellDensityResult?
        >
    with $Provider<OdCellDensityResult?> {
  /// Computed OD / Cell Density result.
  const OdCellDensityResultProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'odCellDensityResultProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$odCellDensityResultHash();

  @$internal
  @override
  $ProviderElement<OdCellDensityResult?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OdCellDensityResult? create(Ref ref) {
    return odCellDensityResult(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OdCellDensityResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OdCellDensityResult?>(value),
    );
  }
}

String _$odCellDensityResultHash() =>
    r'8b92b943eab3600be77be63f4a293f1e12af50bf';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flow_velocity_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Flow Velocity Calculator.
///
/// Formula: V = Q / A
/// Where:
/// - Q: Volumetric flow rate (m³/s)
/// - A: Cross-sectional area (m²)

@ProviderFor(FlowVelocityCalculator)
const flowVelocityCalculatorProvider = FlowVelocityCalculatorProvider._();

/// Flow Velocity Calculator.
///
/// Formula: V = Q / A
/// Where:
/// - Q: Volumetric flow rate (m³/s)
/// - A: Cross-sectional area (m²)
final class FlowVelocityCalculatorProvider
    extends $NotifierProvider<FlowVelocityCalculator, FlowVelocityInput> {
  /// Flow Velocity Calculator.
  ///
  /// Formula: V = Q / A
  /// Where:
  /// - Q: Volumetric flow rate (m³/s)
  /// - A: Cross-sectional area (m²)
  const FlowVelocityCalculatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'flowVelocityCalculatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$flowVelocityCalculatorHash();

  @$internal
  @override
  FlowVelocityCalculator create() => FlowVelocityCalculator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlowVelocityInput value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlowVelocityInput>(value),
    );
  }
}

String _$flowVelocityCalculatorHash() =>
    r'eb31528574176192d35efc8adad930fba1608829';

/// Flow Velocity Calculator.
///
/// Formula: V = Q / A
/// Where:
/// - Q: Volumetric flow rate (m³/s)
/// - A: Cross-sectional area (m²)

abstract class _$FlowVelocityCalculator extends $Notifier<FlowVelocityInput> {
  FlowVelocityInput build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<FlowVelocityInput, FlowVelocityInput>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FlowVelocityInput, FlowVelocityInput>,
              FlowVelocityInput,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Computed flow velocity result.

@ProviderFor(flowVelocityResult)
const flowVelocityResultProvider = FlowVelocityResultProvider._();

/// Computed flow velocity result.

final class FlowVelocityResultProvider
    extends
        $FunctionalProvider<
          FlowVelocityResult?,
          FlowVelocityResult?,
          FlowVelocityResult?
        >
    with $Provider<FlowVelocityResult?> {
  /// Computed flow velocity result.
  const FlowVelocityResultProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'flowVelocityResultProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$flowVelocityResultHash();

  @$internal
  @override
  $ProviderElement<FlowVelocityResult?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FlowVelocityResult? create(Ref ref) {
    return flowVelocityResult(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlowVelocityResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlowVelocityResult?>(value),
    );
  }
}

String _$flowVelocityResultHash() =>
    r'd9c7f4d512d50a3b1c23679e1305b285a6b3d92a';

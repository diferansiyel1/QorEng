import 'package:flutter/material.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';

/// Placeholder screen for Mechanical engineering calculations.
///
/// This module will contain calculations for:
/// - Pump sizing (NPSH, head, flow)
/// - Valve Cv/Kv
/// - Pressure drop
/// - Heat exchanger sizing
/// - Bearing life calculations
class MechanicalScreen extends StatelessWidget {
  const MechanicalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mechanical'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Dimens.spacingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(Dimens.spacingXl),
                decoration: BoxDecoration(
                  color: AppColors.mechanicalAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.settings,
                  size: Dimens.iconXl * 1.5,
                  color: AppColors.mechanicalAccent,
                ),
              ),
              const SizedBox(height: Dimens.spacingXl),
              Text(
                'Mechanical Calculations',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimens.spacingMd),
              Text(
                'Pump Sizing • Valve Cv/Kv • Pressure Drop\nHeat Exchanger • Bearing Life',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimens.spacingXxl),
              Text(
                'Coming Soon',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';

/// Placeholder screen for Bioprocess engineering calculations.
///
/// This module will contain calculations for:
/// - OUR/CER (Oxygen/CO2 uptake rates)
/// - Cell growth kinetics
/// - Bioreactor scale-up
/// - Sterilization (F0/D values)
/// - Media preparation
class BioprocessScreen extends StatelessWidget {
  const BioprocessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bioprocess'),
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
                  color: AppColors.bioprocessAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.biotech,
                  size: Dimens.iconXl * 1.5,
                  color: AppColors.bioprocessAccent,
                ),
              ),
              const SizedBox(height: Dimens.spacingXl),
              Text(
                'Bioprocess Calculations',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimens.spacingMd),
              Text(
                'OUR/CER • Cell Growth Kinetics\nScale-Up • Sterilization • Media Prep',
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

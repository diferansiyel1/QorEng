import 'package:flutter/material.dart';

import 'package:engicore/core/constants/dimens.dart';

/// Base layout widget for calculation screens.
///
/// Provides consistent structure with:
/// - Scrollable input section
/// - Results section
/// - Action buttons area
class CalculationPage extends StatelessWidget {
  const CalculationPage({
    required this.title,
    required this.inputs,
    required this.results,
    this.actions,
    this.description,
    super.key,
  });

  /// Page title displayed in app bar.
  final String title;

  /// Description of the calculation.
  final String? description;

  /// Input fields section.
  final List<Widget> inputs;

  /// Results display section.
  final List<Widget> results;

  /// Action buttons (Calculate, Clear, etc.).
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(Dimens.spacingMd),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Description
                  if (description != null) ...[
                    Container(
                      padding: const EdgeInsets.all(Dimens.spacingMd),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Dimens.radiusMd),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                            size: Dimens.iconMd,
                          ),
                          const SizedBox(width: Dimens.spacingSm),
                          Expanded(
                            child: Text(
                              description!,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimens.spacingLg),
                  ],

                  // Inputs Section
                  Text(
                    'Inputs',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: Dimens.spacingMd),
                  ...inputs.expand((widget) => [
                        widget,
                        const SizedBox(height: Dimens.spacingMd),
                      ]),

                  // Actions
                  if (actions != null && actions!.isNotEmpty) ...[
                    const SizedBox(height: Dimens.spacingSm),
                    ...actions!.expand((widget) => [
                          widget,
                          const SizedBox(height: Dimens.spacingSm),
                        ]),
                  ],

                  // Results Section
                  const SizedBox(height: Dimens.spacingLg),
                  Text(
                    'Results',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: Dimens.spacingMd),
                  ...results.expand((widget) => [
                        widget,
                        const SizedBox(height: Dimens.spacingSm),
                      ]),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

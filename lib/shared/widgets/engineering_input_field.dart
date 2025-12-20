import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';

/// A custom input field for engineering calculations.
///
/// Features:
/// - Numeric keyboard with decimal support
/// - Optional unit selector dropdown
/// - Validation support
/// - Industrial-sized touch targets for gloved use
class EngineeringInputField<T> extends StatelessWidget {
  const EngineeringInputField({
    required this.label,
    required this.controller,
    this.hint,
    this.units,
    this.selectedUnit,
    this.onUnitChanged,
    this.validator,
    this.onChanged,
    this.suffixText,
    this.enabled = true,
    super.key,
  });

  /// Label displayed above the input field.
  final String label;

  /// Controller for the text input.
  final TextEditingController controller;

  /// Hint text shown when field is empty.
  final String? hint;

  /// List of available units for the dropdown.
  final List<T>? units;

  /// Currently selected unit.
  final T? selectedUnit;

  /// Callback when unit selection changes.
  final ValueChanged<T?>? onUnitChanged;

  /// Optional validator function.
  final String? Function(String?)? validator;

  /// Callback when text value changes.
  final ValueChanged<String>? onChanged;

  /// Static suffix text (used when no unit dropdown).
  final String? suffixText;

  /// Whether the field is enabled.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: Dimens.spacingXs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: controller,
                enabled: enabled,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^-?\d*\.?\d*'),
                  ),
                ],
                validator: validator,
                onChanged: onChanged,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: hint ?? 'Enter value',
                  suffixText: suffixText,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Dimens.spacingMd,
                    vertical: Dimens.spacingMd,
                  ),
                ),
              ),
            ),
            if (units != null && units!.isNotEmpty) ...[
              const SizedBox(width: Dimens.spacingSm),
              Expanded(
                flex: 2,
                child: _UnitDropdown<T>(
                  units: units!,
                  selectedUnit: selectedUnit,
                  onChanged: onUnitChanged,
                  enabled: enabled,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Dropdown for unit selection.
class _UnitDropdown<T> extends StatelessWidget {
  const _UnitDropdown({
    required this.units,
    required this.selectedUnit,
    required this.onChanged,
    required this.enabled,
  });

  final List<T> units;
  final T? selectedUnit;
  final ValueChanged<T?>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: Dimens.inputHeightSm,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(Dimens.radiusMd),
        border: Border.all(
          color: isDark
              ? AppColors.textSecondaryDark.withValues(alpha: 0.3)
              : AppColors.textSecondaryLight.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: Dimens.spacingMd),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: selectedUnit,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
          dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
          items: units.map((unit) {
            return DropdownMenuItem<T>(
              value: unit,
              child: Text(
                unit.toString().split('.').last,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }
}

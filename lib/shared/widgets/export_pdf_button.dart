import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/core/services/auth_service.dart';
import 'package:engicore/core/services/pdf_service.dart';
import 'package:engicore/shared/widgets/login_prompt_sheet.dart';

/// A button widget for exporting calculation results as PDF.
///
/// This widget generates a branded Pikolab PDF with the calculation
/// title, inputs, and results, then opens the native share sheet.
class ExportPdfButton extends ConsumerStatefulWidget {
  const ExportPdfButton({
    required this.title,
    required this.inputs,
    required this.results,
    this.color,
    this.requireLogin = false,
    super.key,
  });

  /// Title of the calculation (e.g., "Ohm's Law").
  final String title;

  /// Input parameters as key-value pairs.
  final Map<String, String> inputs;

  /// Calculated results as key-value pairs.
  final Map<String, String> results;

  /// Optional accent color (defaults to teal).
  final Color? color;

  /// If true, requires user login before exporting (soft gate).
  final bool requireLogin;

  @override
  ConsumerState<ExportPdfButton> createState() => _ExportPdfButtonState();
}

class _ExportPdfButtonState extends ConsumerState<ExportPdfButton> {
  bool _isLoading = false;

  Future<void> _handleExport() async {
    // Check if login is required and user is not pro
    if (widget.requireLogin) {
      final isProUser = ref.read(isProUserProvider);
      if (!isProUser) {
        final didLogin = await LoginPromptSheet.show(
          context,
          featureName: 'Export PDF',
          onLoginSuccess: () {},
        );
        if (!didLogin) return;
      }
    }

    // Proceed with PDF generation
    await _exportPdf();
  }

  Future<void> _exportPdf() async {
    setState(() => _isLoading = true);

    try {
      final pdfService = ref.read(pdfServiceProvider);
      await pdfService.generateAndShareReport(
        title: widget.title,
        inputs: widget.inputs,
        results: widget.results,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not generate report'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final buttonColor = widget.color ?? AppColors.primary;

    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _handleExport,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: Dimens.spacingMd,
          vertical: Dimens.spacingSm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radiusMd),
        ),
        elevation: Dimens.elevationSm,
      ),
      icon: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.picture_as_pdf, size: 20),
      label: Text(
        _isLoading ? 'Generating...' : 'Export PDF',
        style: theme.textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// A compact icon-only version of the export button.
class ExportPdfIconButton extends ConsumerStatefulWidget {
  const ExportPdfIconButton({
    required this.title,
    required this.inputs,
    required this.results,
    this.color,
    super.key,
  });

  final String title;
  final Map<String, String> inputs;
  final Map<String, String> results;
  final Color? color;

  @override
  ConsumerState<ExportPdfIconButton> createState() =>
      _ExportPdfIconButtonState();
}

class _ExportPdfIconButtonState extends ConsumerState<ExportPdfIconButton> {
  bool _isLoading = false;

  Future<void> _exportPdf() async {
    setState(() => _isLoading = true);

    try {
      final pdfService = ref.read(pdfServiceProvider);
      await pdfService.generateAndShareReport(
        title: widget.title,
        inputs: widget.inputs,
        results: widget.results,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not generate report'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? Colors.red;

    return IconButton(
      onPressed: _isLoading ? null : _exportPdf,
      icon: _isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(buttonColor),
              ),
            )
          : Icon(
              Icons.picture_as_pdf,
              color: buttonColor,
            ),
      tooltip: 'Export as PDF',
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/core/localization/localization_service.dart';
import 'package:engicore/features/field_logger/domain/entities/log_session.dart';
import 'package:engicore/features/field_logger/domain/repositories/field_logger_repository.dart';

/// Screen for creating a new logging session.
class CreateSessionScreen extends ConsumerStatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  ConsumerState<CreateSessionScreen> createState() =>
      _CreateSessionScreenState();
}

class _CreateSessionScreenState extends ConsumerState<CreateSessionScreen> {
  final _sessionNameController = TextEditingController();
  final _parameters = <_ParameterEntry>[];
  final _formKey = GlobalKey<FormState>();

  // Default parameter suggestions
  static const _defaultSuggestions = [
    ('Viscosity', 'cP'),
    ('Temperature', '°C'),
    ('Pressure', 'Bar'),
    ('pH', 'pH'),
    ('Density', 'g/mL'),
    ('Conductivity', 'mS/cm'),
  ];

  @override
  void initState() {
    super.initState();
    // Add one default parameter row
    _addParameter();
  }

  @override
  void dispose() {
    _sessionNameController.dispose();
    for (final param in _parameters) {
      param.nameController.dispose();
    }
    super.dispose();
  }

  void _addParameter() {
    setState(() {
      _parameters.add(_ParameterEntry(
        nameController: TextEditingController(),
        unit: 'cP',
      ));
    });
  }

  void _removeParameter(int index) {
    if (_parameters.length > 1) {
      setState(() {
        _parameters[index].nameController.dispose();
        _parameters.removeAt(index);
      });
    }
  }

  void _applySuggestion(int index, String name, String unit) {
    setState(() {
      _parameters[index].nameController.text = name;
      _parameters[index].unit = unit;
    });
  }

  void _startLogging() {
    if (!_formKey.currentState!.validate()) return;

    // Create log parameters from entries
    final logParams = _parameters
        .where((p) => p.nameController.text.trim().isNotEmpty)
        .map((p) => LogParameter(
              name: p.nameController.text.trim(),
              unit: p.unit,
            ))
        .toList();

    if (logParams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one parameter')),
      );
      return;
    }

    // Create the session
    final session = LogSession(
      title: _sessionNameController.text.trim(),
      parameters: logParams,
    );

    // Set active session and navigate
    ref.read(activeSessionProvider.notifier).setSession(session);
    context.go('/field-logger/active');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final strings = ref.strings;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.fieldLogger),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimens.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Session Name
              Text(
                strings.sessionName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Dimens.spacingSm),
              TextFormField(
                controller: _sessionNameController,
                decoration: InputDecoration(
                  hintText: strings.sessionNameHint,
                  prefixIcon: const Icon(Icons.edit_note_rounded),
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimens.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return strings.enterSessionName;
                  }
                  return null;
                },
              ),

              const SizedBox(height: Dimens.spacingXl),

              // Parameters section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings.parameters,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addParameter,
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: Text(strings.addParameter),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimens.spacingSm),

              // Quick suggestions
              Wrap(
                spacing: Dimens.spacingSm,
                runSpacing: Dimens.spacingSm,
                children: _defaultSuggestions.map((suggestion) {
                  return ActionChip(
                    label: Text('${suggestion.$1} (${suggestion.$2})'),
                    avatar: const Icon(Icons.add, size: 16),
                    onPressed: () {
                      // Find first empty parameter slot or add new
                      final emptyIndex = _parameters.indexWhere(
                        (p) => p.nameController.text.isEmpty,
                      );
                      if (emptyIndex >= 0) {
                        _applySuggestion(
                            emptyIndex, suggestion.$1, suggestion.$2);
                      } else {
                        _addParameter();
                        Future.delayed(const Duration(milliseconds: 50), () {
                          _applySuggestion(
                            _parameters.length - 1,
                            suggestion.$1,
                            suggestion.$2,
                          );
                        });
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: Dimens.spacingMd),

              // Parameter list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _parameters.length,
                itemBuilder: (context, index) {
                  return _ParameterRow(
                    entry: _parameters[index],
                    index: index,
                    canDelete: _parameters.length > 1,
                    onDelete: () => _removeParameter(index),
                    onUnitChanged: (unit) {
                      setState(() {
                        _parameters[index].unit = unit;
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: Dimens.spacingXl),

              // Previous Sessions
              _PreviousSessionsList(
                onSessionSelected: (session) {
                  // Set active session and navigate to summary
                  ref.read(activeSessionProvider.notifier).setSession(session);
                  context.go('/field-logger/summary');
                },
              ),

              const SizedBox(height: Dimens.spacingXl),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Dimens.spacingLg),
          child: ElevatedButton(
            onPressed: _startLogging,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimens.radiusMd),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow_rounded, size: 24),
                const SizedBox(width: Dimens.spacingSm),
                Text(
                  strings.startLogging,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Internal class to hold parameter entry state.
class _ParameterEntry {
  _ParameterEntry({
    required this.nameController,
    required this.unit,
  });

  final TextEditingController nameController;
  String unit;
}

/// Widget for a single parameter row.
class _ParameterRow extends StatelessWidget {
  const _ParameterRow({
    required this.entry,
    required this.index,
    required this.canDelete,
    required this.onDelete,
    required this.onUnitChanged,
  });

  final _ParameterEntry entry;
  final int index;
  final bool canDelete;
  final VoidCallback onDelete;
  final ValueChanged<String> onUnitChanged;

  static const _units = [
    'cP',
    '°C',
    'Bar',
    'pH',
    'g/mL',
    'mS/cm',
    'ppm',
    '%',
    'mg/L',
    'mPa.s',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimens.spacingMd),
      child: Container(
        padding: const EdgeInsets.all(Dimens.spacingMd),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(Dimens.radiusMd),
          border: Border.all(
            color: isDark
                ? AppColors.textSecondaryDark.withValues(alpha: 0.2)
                : AppColors.textSecondaryLight.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            // Parameter number
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(Dimens.radiusSm),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: Dimens.spacingMd),

            // Parameter name field
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: entry.nameController,
                decoration: InputDecoration(
                  hintText: 'Parameter name',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimens.radiusSm),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Dimens.spacingMd,
                    vertical: Dimens.spacingSm,
                  ),
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ),
            const SizedBox(width: Dimens.spacingSm),

            // Unit dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Dimens.spacingSm),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark
                      ? AppColors.textSecondaryDark.withValues(alpha: 0.3)
                      : AppColors.textSecondaryLight.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(Dimens.radiusSm),
              ),
              child: DropdownButton<String>(
                value: entry.unit,
                underline: const SizedBox(),
                isDense: true,
                items: _units.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    onUnitChanged(value);
                  }
                },
              ),
            ),

            // Delete button
            if (canDelete)
              IconButton(
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: AppColors.error.withValues(alpha: 0.7),
                ),
                onPressed: onDelete,
                tooltip: 'Remove parameter',
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget showing previous sessions.
class _PreviousSessionsList extends ConsumerWidget {
  const _PreviousSessionsList({
    required this.onSessionSelected,
  });

  final ValueChanged<LogSession> onSessionSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sessions = ref.watch(logSessionsProvider);

    // Show only last 5 sessions
    final recentSessions = sessions.take(5).toList();

    if (recentSessions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Son Oturumlar',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: Dimens.spacingSm),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentSessions.length,
          itemBuilder: (context, index) {
            final session = recentSessions[index];
            final dateStr =
                '${session.startTime.day}/${session.startTime.month}/${session.startTime.year}';
            final timeStr =
                '${session.startTime.hour.toString().padLeft(2, '0')}:${session.startTime.minute.toString().padLeft(2, '0')}';

            return Container(
              margin: const EdgeInsets.only(bottom: Dimens.spacingSm),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(Dimens.radiusMd),
                border: Border.all(
                  color: isDark
                      ? AppColors.textSecondaryDark.withValues(alpha: 0.2)
                      : AppColors.textSecondaryLight.withValues(alpha: 0.2),
                ),
              ),
              child: ListTile(
                dense: true,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(Dimens.radiusSm),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
                title: Text(
                  session.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '$dateStr $timeStr • ${session.entries.length} kayıt',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: AppColors.error.withValues(alpha: 0.7),
                        size: 20,
                      ),
                      onPressed: () {
                        ref
                            .read(logSessionsProvider.notifier)
                            .deleteSession(session.id);
                      },
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => onSessionSelected(session),
              ),
            );
          },
        ),
      ],
    );
  }
}

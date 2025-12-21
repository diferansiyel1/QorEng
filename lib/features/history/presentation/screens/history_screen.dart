import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/features/history/domain/entities/calculation_record.dart';
import 'package:engicore/features/history/domain/repositories/history_repository.dart';

/// Screen displaying calculation history.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(historyRecordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: true,
        actions: [
          if (records.isNotEmpty)
            IconButton(
              onPressed: () => _showDeleteDialog(context, ref),
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear History',
            ),
        ],
      ),
      body: records.isEmpty
          ? const _EmptyHistoryView()
          : _HistoryListView(records: records),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to delete all calculation history? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(historyRecordsProvider.notifier).clearAll();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}

/// Empty state view when no history exists.
class _EmptyHistoryView extends StatelessWidget {
  const _EmptyHistoryView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimens.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: Dimens.iconXl * 2,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: Dimens.spacingLg),
            Text(
              'No Calculations Yet',
              style: theme.textTheme.titleLarge?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: Dimens.spacingMd),
            Text(
              'Your calculation history will appear here.\n'
              'Start by using any calculator!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// List view of history records.
class _HistoryListView extends StatelessWidget {
  const _HistoryListView({required this.records});

  final List<CalculationRecord> records;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(Dimens.spacingMd),
      itemCount: records.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: Dimens.spacingSm),
      itemBuilder: (context, index) {
        return _RecordTile(record: records[index]);
      },
    );
  }
}

/// Single history record tile.
class _RecordTile extends ConsumerWidget {
  const _RecordTile({required this.record});

  final CalculationRecord record;

  IconData get _moduleIcon {
    return switch (record.moduleType) {
      ModuleType.electrical => Icons.electric_bolt,
      ModuleType.mechanical => Icons.settings,
      ModuleType.chemical => Icons.science,
      ModuleType.bioprocess => Icons.biotech,
      ModuleType.other => Icons.calculate,
    };
  }

  Color get _moduleColor {
    return switch (record.moduleType) {
      ModuleType.electrical => AppColors.electricalAccent,
      ModuleType.mechanical => AppColors.mechanicalAccent,
      ModuleType.chemical => AppColors.chemicalAccent,
      ModuleType.bioprocess => AppColors.bioprocessAccent,
      ModuleType.other => AppColors.accent,
    };
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final recordDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    final timeFormat = DateFormat.Hm();
    final timeStr = timeFormat.format(timestamp);

    if (recordDate == today) {
      return 'Today, $timeStr';
    } else if (recordDate == yesterday) {
      return 'Yesterday, $timeStr';
    } else {
      final dateFormat = DateFormat.MMMd();
      return '${dateFormat.format(timestamp)}, $timeStr';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: Dimens.spacingMd),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(Dimens.radiusMd),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(historyRecordsProvider.notifier).deleteRecord(record.id);
      },
      child: Card(
        elevation: Dimens.elevationSm,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Dimens.spacingMd,
            vertical: Dimens.spacingXs,
          ),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _moduleColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(Dimens.radiusMd),
            ),
            child: Icon(
              _moduleIcon,
              color: _moduleColor,
              size: Dimens.iconMd,
            ),
          ),
          title: Text(
            record.title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            _formatTimestamp(record.timestamp),
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          trailing: Text(
            record.resultValue,
            style: theme.textTheme.titleMedium?.copyWith(
              color: _moduleColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

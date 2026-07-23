import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/arabic_numerals.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../auth/application/auth_controller.dart';
import '../data/dashboard_repository.dart';
import '../data/dashboard_stats.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final userAsync = ref.watch(currentUserProvider);
    final fg = Theme.of(context).textTheme.bodyMedium?.color;
    final l10n = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: () => ref.refresh(dashboardStatsProvider.future),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          userAsync.when(
            data: (user) => Text(
              l10n.dashboardGreeting(user.name),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontSize: 21),
            ),
            loading: () => const SizedBox(height: 28),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 18),
          statsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text(l10n.failedToLoadStats(err.toString())),
            data: (stats) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatGrid(stats: stats),
                const SizedBox(height: 20),
                _ProgressBar(stats: stats, fg: fg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final divider = Theme.of(context).dividerColor;
    final l10n = AppLocalizations.of(context)!;
    final cells = [
      (
        Icons.local_fire_department,
        localizedDigits(context, stats.streak),
        l10n.streakDays,
      ),
      (
        Icons.menu_book_outlined,
        localizedDigits(context, stats.enrolled),
        l10n.enrolledCourses,
      ),
      (
        Icons.check_circle_outline,
        localizedDigits(context, stats.completed),
        l10n.completedCourses,
      ),
    ];

    return Container(
      decoration: BoxDecoration(border: Border.all(color: divider, width: 2)),
      child: Row(
        children: List.generate(cells.length, (i) {
          final (icon, value, label) = cells[i];
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: i < cells.length - 1
                    ? Border(right: BorderSide(color: divider, width: 2))
                    : null,
              ),
              child: Column(
                children: [
                  Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 4),
                  Text(value, style: AppTextStyles.brand(context, size: 18)),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.stats, required this.fg});
  final DashboardStats stats;
  final Color? fg;

  @override
  Widget build(BuildContext context) {
    final ratio = stats.enrolled == 0
        ? 0.0
        : (stats.completed / stats.enrolled).clamp(0, 1).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.overallProgress,
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              '${localizedDigits(context, (ratio * 100).round())}٪',
              style: TextStyle(fontSize: 12, color: fg?.withValues(alpha: 0.6)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 8,
          child: ClipRect(
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: AppColors.neutral300,
            ),
          ),
        ),
      ],
    );
  }
}

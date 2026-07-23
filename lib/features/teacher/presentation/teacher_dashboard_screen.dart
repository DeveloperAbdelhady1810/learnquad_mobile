import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/arabic_numerals.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../auth/application/auth_controller.dart';
import '../../profile/presentation/profile_screen.dart';
import '../data/teacher_stats_models.dart';
import '../data/teacher_stats_repository.dart';

/// Read-only teacher view, per the locked-in v1 scope: analytics only, no
/// course/video authoring or upload from mobile — that stays web-only.
class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(teacherStatsProvider);
    final coursesAsync = ref.watch(teacherCoursesProvider);
    final userAsync = ref.watch(currentUserProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: userAsync.maybeWhen(
          data: (u) => Text(l10n.teacherGreeting(u.name)),
          orElse: () => Text(l10n.teacherDashboardTitle),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: l10n.profileTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(teacherStatsProvider);
          ref.invalidate(teacherCoursesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text(l10n.failedToLoadStats(err.toString())),
              data: (stats) => _StatGrid(stats: stats),
            ),
            const SizedBox(height: 22),
            Text(
              l10n.enrollmentByCourse,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 10),
            coursesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text(l10n.failedToLoadCourses(err.toString())),
              data: (courses) {
                if (courses.isEmpty) {
                  return Text(l10n.noCoursesYetPlain);
                }
                final maxEnrollment = courses
                    .map((c) => c.enrollmentCount)
                    .fold<int>(0, (a, b) => a > b ? a : b);
                return Column(
                  children: courses
                      .map(
                        (c) => _CourseEnrollmentRow(
                          course: c,
                          ratio: maxEnrollment == 0
                              ? 0.0
                              : c.enrollmentCount / maxEnrollment,
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.stats});
  final TeacherStats stats;

  @override
  Widget build(BuildContext context) {
    final divider = Theme.of(context).dividerColor;
    final l10n = AppLocalizations.of(context)!;
    final cells = [
      (localizedDigits(context, stats.students), l10n.totalStudents, false),
      (
        '${localizedDigits(context, stats.revenue.toStringAsFixed(0))} ${l10n.currencySuffix}',
        l10n.totalRevenue,
        true,
      ),
      (localizedDigits(context, stats.courses), l10n.activeCourses, false),
    ];

    return Container(
      decoration: BoxDecoration(border: Border.all(color: divider, width: 2)),
      child: Row(
        children: List.generate(cells.length, (i) {
          final (value, label, accent) = cells[i];
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
              decoration: BoxDecoration(
                border: i < cells.length - 1
                    ? Border(right: BorderSide(color: divider, width: 2))
                    : null,
              ),
              child: Column(
                children: [
                  Text(
                    value,
                    style: AppTextStyles.brand(
                      context,
                      size: 20,
                      color: accent
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.5,
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

class _CourseEnrollmentRow extends StatelessWidget {
  const _CourseEnrollmentRow({required this.course, required this.ratio});
  final TeacherCourseRow course;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).textTheme.bodyMedium?.color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  course.title,
                  style: const TextStyle(fontSize: 12.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${localizedDigits(context, course.enrollmentCount)} '
                '${AppLocalizations.of(context)!.studentsSuffix}',
                style: TextStyle(
                  fontSize: 12,
                  color: fg?.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/arabic_numerals.dart';
import '../../auth/application/auth_controller.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: userAsync.maybeWhen(
          data: (u) => Text('أهلاً ${u.name}'),
          orElse: () => const Text('لوحة المدرس'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'تسجيل الخروج',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).logout(),
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
              error: (err, _) => Text('تعذّر تحميل الإحصائيات: $err'),
              data: (stats) => _StatGrid(stats: stats),
            ),
            const SizedBox(height: 22),
            Text(
              'التسجيل حسب الكورس',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 10),
            coursesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('تعذّر تحميل الكورسات: $err'),
              data: (courses) {
                if (courses.isEmpty) {
                  return const Text('لا توجد كورسات بعد.');
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
    final cells = [
      (arDigits(stats.students), 'إجمالي الطلاب', false),
      ('${arDigits(stats.revenue.toStringAsFixed(0))} ج', 'إجمالي الإيراد', true),
      (arDigits(stats.courses), 'كورسات نشطة', false),
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
                      size: 20,
                      color: accent ? AppColors.accent : null,
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
                '${arDigits(course.enrollmentCount)} طالب',
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

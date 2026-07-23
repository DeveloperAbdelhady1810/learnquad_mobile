import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/arabic_numerals.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../application/learning_providers.dart';
import '../data/my_course_models.dart';

const _swatches = [
  Color(0xFF7C1405),
  Color(0xFF8B2E1F),
  Color(0xFF605D5D),
  Color(0xFF444141),
];

class MyCoursesScreen extends ConsumerWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(myCoursesProvider);
    final l10n = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: () => ref.refresh(myCoursesProvider.future),
      child: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text(l10n.failedToLoadMyCourses(err.toString()))),
        data: (courses) {
          if (courses.isEmpty) {
            return ListView(
              children: [
                const SizedBox(height: 120),
                Center(child: Text(l10n.noCoursesPurchasedYet)),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _MyCourseCard(course: courses[index]),
          );
        },
      ),
    );
  }
}

class _MyCourseCard extends StatelessWidget {
  const _MyCourseCard({required this.course});
  final MyCourse course;

  @override
  Widget build(BuildContext context) {
    final color = _swatches[course.id % _swatches.length];
    final fg = Theme.of(context).textTheme.bodyMedium?.color;

    return Material(
      color: Theme.of(context).cardTheme.color,
      child: InkWell(
        onTap: () => context.push('/my-courses/${course.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 48, height: 48, color: color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontSize: 15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (course.teacherName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            course.teacherName!,
                            style: TextStyle(
                              fontSize: 13,
                              color: fg?.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 6,
                      child: ClipRect(
                        child: LinearProgressIndicator(
                          value: course.progress / 100,
                          backgroundColor: AppColors.neutral300,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${localizedDigits(context, course.progress)}٪',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

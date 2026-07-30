import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/color_utils.dart';
import '../../../core/utils/arabic_numerals.dart';
import '../../../core/widgets/app_tag.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../application/teacher_providers.dart';
import '../data/teacher_models.dart';

class TeacherDetailScreen extends ConsumerWidget {
  const TeacherDetailScreen({super.key, required this.teacherId});
  final int teacherId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teacherAsync = ref.watch(teacherDetailProvider(teacherId));
    final accent = Theme.of(context).colorScheme.primary;
    final fg = Theme.of(context).textTheme.bodyMedium?.color;
    final divider = Theme.of(context).dividerColor;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.teacherProfileTitle)),
      body: teacherAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text(l10n.failedToLoadTeacher(err.toString()))),
        data: (teacher) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: shadeColor(accent, 0.55),
                  child: Text(
                    teacher.name.isNotEmpty ? teacher.name[0] : '؟',
                    style: AppTextStyles.brand(
                      context,
                      size: 22,
                      color: tintColor(accent, 0.90),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teacher.name,
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontSize: 18),
                      ),
                      if (teacher.subjects.isNotEmpty ||
                          teacher.educationStages.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            ...teacher.subjects.map(
                              (s) => AppTag(s, variant: AppTagVariant.accent),
                            ),
                            ...teacher.educationStages.map(
                              (s) => AppTag(s, variant: AppTagVariant.neutral),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (teacher.bio != null) ...[
              const SizedBox(height: 20),
              Text(
                teacher.bio!,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.8,
                  color: fg?.withValues(alpha: 0.85),
                ),
              ),
            ],
            if (teacher.email != null) ...[
              const SizedBox(height: 16),
              Divider(color: divider),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.mail_outline,
                    size: 16,
                    color: fg?.withValues(alpha: 0.55),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    teacher.email!,
                    style: TextStyle(
                      fontSize: 12,
                      color: fg?.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Divider(color: divider),
            const SizedBox(height: 16),
            Text(
              l10n.hisCourses,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 10),
            if (teacher.courses.isEmpty)
              Text(
                l10n.noPublishedCoursesYet,
                style: TextStyle(color: fg?.withValues(alpha: 0.6)),
              )
            else
              ...teacher.courses.map((c) => _TeacherCourseTile(course: c)),
          ],
        ),
      ),
    );
  }
}

const _swatches = [
  AppColors.accent500,
  AppColors.accent700,
  AppColors.neutral600,
  AppColors.neutral800,
];

class _TeacherCourseTile extends StatelessWidget {
  const _TeacherCourseTile({required this.course});
  final TeacherCourseSummary course;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _swatches[course.id % _swatches.length];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppRadius.mdBr,
          border: Border.all(color: AppElevation.ringSm(isDark)),
          boxShadow: AppElevation.sm(isDark),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => context.push('/courses/${course.id}'),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: AppRadius.smBr,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${localizedDigits(context, course.price.toStringAsFixed(0))} '
                          '${AppLocalizations.of(context)!.currencySuffix}',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Theme.of(context).textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

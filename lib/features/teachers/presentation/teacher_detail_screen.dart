import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/arabic_numerals.dart';
import '../application/teacher_providers.dart';
import '../data/teacher_models.dart';

class TeacherDetailScreen extends ConsumerWidget {
  const TeacherDetailScreen({super.key, required this.teacherId});
  final int teacherId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teacherAsync = ref.watch(teacherDetailProvider(teacherId));
    final fg = Theme.of(context).textTheme.bodyMedium?.color;

    return Scaffold(
      appBar: AppBar(title: const Text('ملف المدرس')),
      body: teacherAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('تعذّر تحميل بيانات المدرس: $err')),
        data: (teacher) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.neutral300,
                  child: Text(
                    teacher.name.isNotEmpty ? teacher.name[0] : '؟',
                    style: AppTextStyles.brand(size: 24, color: fg),
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
                        const SizedBox(height: 2),
                        Text(
                          [
                            ...teacher.subjects,
                            ...teacher.educationStages,
                          ].join(' · '),
                          style: TextStyle(
                            fontSize: 13,
                            color: fg?.withValues(alpha: 0.65),
                          ),
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
            const SizedBox(height: 20),
            Text(
              'كورساته',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 10),
            if (teacher.courses.isEmpty)
              Text(
                'لا توجد كورسات منشورة حالياً.',
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
  Color(0xFF7C1405),
  Color(0xFF8B2E1F),
  Color(0xFF605D5D),
  Color(0xFF444141),
];

class _TeacherCourseTile extends StatelessWidget {
  const _TeacherCourseTile({required this.course});
  final TeacherCourseSummary course;

  @override
  Widget build(BuildContext context) {
    final color = _swatches[course.id % _swatches.length];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Theme.of(context).cardTheme.color,
        child: InkWell(
          onTap: () => context.push('/courses/${course.id}'),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(width: 40, height: 40, color: color),
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
                        '${arDigits(course.price.toStringAsFixed(0))} ج.م',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
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
    );
  }
}

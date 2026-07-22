import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../application/teacher_providers.dart';
import '../data/teacher_models.dart';

class TeacherDetailScreen extends ConsumerWidget {
  const TeacherDetailScreen({super.key, required this.teacherId});
  final int teacherId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teacherAsync = ref.watch(teacherDetailProvider(teacherId));

    return Scaffold(
      appBar: AppBar(title: const Text('Teacher')),
      body: teacherAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(child: Text('Failed to load teacher: $err')),
        data: (teacher) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: Text(
                teacher.name.isNotEmpty ? teacher.name[0] : '?',
                style: const TextStyle(
                  fontSize: 28,
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              teacher.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (teacher.subjects.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                teacher.subjects.join(', '),
                style: const TextStyle(color: Colors.black54),
              ),
            ],
            if (teacher.bio != null) ...[
              const Divider(height: 32),
              Text('Bio', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(teacher.bio!),
            ],
            const Divider(height: 32),
            Text('Courses', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...teacher.courses.map((c) => _TeacherCourseTile(course: c)),
          ],
        ),
      ),
    );
  }
}

class _TeacherCourseTile extends StatelessWidget {
  const _TeacherCourseTile({required this.course});
  final TeacherCourseSummary course;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => context.push('/courses/${course.id}'),
        title: Text(course.title),
        trailing: Text(
          '${course.price.toStringAsFixed(0)} EGP',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

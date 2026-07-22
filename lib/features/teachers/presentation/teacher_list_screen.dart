import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../application/teacher_providers.dart';
import '../data/teacher_models.dart';

class TeacherListScreen extends ConsumerStatefulWidget {
  const TeacherListScreen({super.key});

  @override
  ConsumerState<TeacherListScreen> createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends ConsumerState<TeacherListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherListProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search teachers...',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (value) =>
                ref.read(teacherListProvider.notifier).search(value),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(teacherListProvider.notifier).refresh(),
            child: state.isLoading && state.teachers.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : state.errorMessage != null && state.teachers.isEmpty
                ? Center(child: Text(state.errorMessage!))
                : state.teachers.isEmpty
                ? const Center(child: Text('No teachers found.'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.teachers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) =>
                        _TeacherTile(teacher: state.teachers[index]),
                  ),
          ),
        ),
      ],
    );
  }
}

class _TeacherTile extends StatelessWidget {
  const _TeacherTile({required this.teacher});
  final TeacherSummary teacher;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: () => context.push('/teachers/${teacher.id}'),
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: Text(
            teacher.name.isNotEmpty ? teacher.name[0] : '?',
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          teacher.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: teacher.subjects.isNotEmpty
            ? Text(teacher.subjects.join(', '))
            : null,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

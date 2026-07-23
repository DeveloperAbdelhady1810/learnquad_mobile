import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/gen/app_localizations.dart';
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _searchController,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchTeachersHint,
              prefixIcon: const Icon(Icons.search, size: 18),
            ),
            onSubmitted: (value) =>
                ref.read(teacherListProvider.notifier).search(value),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(teacherListProvider.notifier).refresh(),
            child: state.isLoading && state.teachers.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.errorMessage != null && state.teachers.isEmpty
                ? Center(child: Text(state.errorMessage!))
                : state.teachers.isEmpty
                ? Center(child: Text(AppLocalizations.of(context)!.noTeachersYet))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.teachers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
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
    final fg = Theme.of(context).textTheme.bodyMedium?.color;
    return Material(
      color: Theme.of(context).cardTheme.color,
      child: InkWell(
        onTap: () => context.push('/teachers/${teacher.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.neutral300,
                child: Text(
                  teacher.name.isNotEmpty ? teacher.name[0] : '؟',
                  style: AppTextStyles.brand(context, size: 16, color: fg),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.name,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontSize: 15),
                    ),
                    if (teacher.subjects.isNotEmpty || teacher.educationStages.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        [
                          ...teacher.subjects,
                          ...teacher.educationStages,
                        ].join(' · '),
                        style: TextStyle(
                          fontSize: 13,
                          color: fg?.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_left, color: fg?.withValues(alpha: 0.4)),
            ],
          ),
        ),
      ),
    );
  }
}

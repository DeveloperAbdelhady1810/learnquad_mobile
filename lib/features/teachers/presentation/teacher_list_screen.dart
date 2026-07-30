import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/color_utils.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;
    final fg = Theme.of(context).textTheme.bodyMedium?.color;
    return Container(
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
          onTap: () => context.push('/teachers/${teacher.id}'),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: shadeColor(accent, 0.55),
                  child: Text(
                    teacher.name.isNotEmpty ? teacher.name[0] : '؟',
                    style: AppTextStyles.brand(
                      context,
                      size: 15,
                      color: tintColor(accent, 0.90),
                    ),
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
      ),
    );
  }
}

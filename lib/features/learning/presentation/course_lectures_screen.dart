import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/arabic_numerals.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../courses/data/course_models.dart';
import '../../quizzes/presentation/quiz_list_screen.dart';
import '../application/learning_providers.dart';
import 'lecture_watch_screen.dart';

class CourseLecturesScreen extends ConsumerWidget {
  const CourseLecturesScreen({super.key, required this.courseId});
  final int courseId;

  void _watchLecture(
    BuildContext context,
    List<CourseSection> sections,
    CourseLecture lecture,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LectureWatchScreen(
          courseId: courseId,
          sections: sections,
          initialLectureId: lecture.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(courseLecturesProvider(courseId));
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.courseTitleFallback),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.tabContent, icon: const Icon(Icons.menu_book_outlined)),
              Tab(text: l10n.tabQuizzes, icon: const Icon(Icons.quiz_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            sectionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text(l10n.failedToLoadLectures(err.toString())),
              ),
              data: (sections) {
                final allLectures = sections.expand((s) => s.lectures).toList();
                final completed = allLectures
                    .where((l) => l.completed == true)
                    .length;
                final progress = allLectures.isEmpty
                    ? 0.0
                    : completed / allLectures.length;
                final fg = Theme.of(context).textTheme.bodyMedium?.color;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: AppRadius.smBr,
                              child: SizedBox(
                                height: 6,
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: AppColors.neutral300,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            localizedPercent(context, progress * 100),
                            style: TextStyle(
                              fontSize: 11,
                              color: fg?.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: sections
                            .map(
                              (section) => _SectionBlock(
                                section: section,
                                onTapLecture: (lecture) =>
                                    _watchLecture(context, sections, lecture),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
            QuizListScreen(courseId: courseId),
          ],
        ),
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.section, required this.onTapLecture});
  final CourseSection section;
  final void Function(CourseLecture lecture) onTapLecture;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = Theme.of(context).textTheme.bodyMedium?.color;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.6,
              color: fg?.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: AppRadius.mdBr,
              border: Border.all(color: AppElevation.ringSm(isDark)),
              boxShadow: AppElevation.sm(isDark),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                children: section.lectures.map((lecture) {
                  final completed = lecture.completed == true;
                  return InkWell(
                    onTap: () => onTapLecture(lecture),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            completed
                                ? Icons.check_circle
                                : Icons.play_circle_outline,
                            size: 18,
                            color: completed
                                ? Theme.of(context).colorScheme.primary
                                : fg?.withValues(alpha: 0.55),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              lecture.title,
                              style: const TextStyle(fontSize: 13.5),
                            ),
                          ),
                          if (!completed &&
                              (lecture.progressPercentage ?? 0) > 0)
                            Text(
                              localizedPercent(
                                context,
                                lecture.progressPercentage ?? 0,
                              ),
                              style: TextStyle(
                                fontSize: 11,
                                color: fg?.withValues(alpha: 0.55),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

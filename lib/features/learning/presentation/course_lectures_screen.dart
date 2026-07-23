import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/arabic_numerals.dart';
import '../../../core/webview/bridge_webview_screen.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../courses/data/course_models.dart';
import '../../purchase/data/webview_ticket_repository.dart';
import '../../quizzes/presentation/quiz_list_screen.dart';
import '../application/learning_providers.dart';
import '../data/learning_repository.dart';

class CourseLecturesScreen extends ConsumerWidget {
  const CourseLecturesScreen({super.key, required this.courseId});
  final int courseId;

  Future<void> _watchLecture(
    BuildContext context,
    WidgetRef ref,
    CourseLecture lecture,
  ) async {
    try {
      final bridgeUrl = await ref
          .read(webviewTicketRepositoryProvider)
          .requestLearnTicket(courseId: courseId, lectureId: lecture.id);

      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              BridgeWebViewScreen(initialUrl: bridgeUrl, title: lecture.title),
        ),
      );

      // The web player tracks its own progress; mark complete natively too so
      // the app's own lists (My Courses progress bar) update immediately
      // without waiting on the next full refresh.
      await ref
          .read(learningRepositoryProvider)
          .markLectureComplete(lecture.id);
      ref.invalidate(courseLecturesProvider(courseId));
      ref.invalidate(myCoursesProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.failedToOpenLecture(e.toString()),
            ),
          ),
        );
      }
    }
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
                            child: SizedBox(
                              height: 6,
                              child: ClipRect(
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: AppColors.neutral300,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${localizedDigits(context, (progress * 100).round())}٪',
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
                                    _watchLecture(context, ref, lecture),
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
    final fg = Theme.of(context).textTheme.bodyMedium?.color;
    final divider = Theme.of(context).dividerColor;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 8),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: divider, width: 2)),
            ),
            child: Text(
              section.title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
          ),
          ...section.lectures.map((lecture) {
            final completed = lecture.completed == true;
            return InkWell(
              onTap: () => onTapLecture(lecture),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: divider)),
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
                    if (!completed && (lecture.progressPercentage ?? 0) > 0)
                      Text(
                        '${localizedDigits(context, lecture.progressPercentage ?? 0)}٪',
                        style: TextStyle(
                          fontSize: 11,
                          color: fg?.withValues(alpha: 0.55),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

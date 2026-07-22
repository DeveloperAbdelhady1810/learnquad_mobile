import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/webview/bridge_webview_screen.dart';
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open lecture: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(courseLecturesProvider(courseId));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Course'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Content', icon: Icon(Icons.menu_book_outlined)),
              Tab(text: 'Quizzes', icon: Icon(Icons.quiz_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            sectionsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, _) =>
                  Center(child: Text('Failed to load lectures: $err')),
              data: (sections) => ListView(
                padding: const EdgeInsets.all(16),
                children: sections
                    .map(
                      (section) => _SectionCard(
                        section: section,
                        onTapLecture: (lecture) =>
                            _watchLecture(context, ref, lecture),
                      ),
                    )
                    .toList(),
              ),
            ),
            QuizListScreen(courseId: courseId),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section, required this.onTapLecture});
  final CourseSection section;
  final void Function(CourseLecture lecture) onTapLecture;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(
          section.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        initiallyExpanded: true,
        children: section.lectures.map((lecture) {
          final completed = lecture.completed == true;
          return ListTile(
            onTap: () => onTapLecture(lecture),
            leading: Icon(
              completed ? Icons.check_circle : Icons.play_circle_outline,
              color: completed ? AppColors.primary : Colors.black45,
            ),
            title: Text(lecture.title),
            subtitle: !completed && (lecture.progressPercentage ?? 0) > 0
                ? Text('${lecture.progressPercentage}% watched')
                : null,
          );
        }).toList(),
      ),
    );
  }
}

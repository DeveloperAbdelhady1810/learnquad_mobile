import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../application/quiz_providers.dart';
import '../data/quiz_models.dart';
import 'quiz_result_screen.dart';
import 'quiz_taking_screen.dart';

class QuizListScreen extends ConsumerWidget {
  const QuizListScreen({super.key, required this.courseId});
  final int courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzesAsync = ref.watch(courseQuizzesProvider(courseId));

    return quizzesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (err, _) => Center(child: Text('Failed to load quizzes: $err')),
      data: (quizzes) {
        if (quizzes.isEmpty) {
          return const Center(child: Text('No quizzes for this course yet.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: quizzes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _QuizCard(quiz: quizzes[index]),
        );
      },
    );
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({required this.quiz});
  final QuizSummary quiz;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(
          quiz.submitted ? Icons.fact_check : Icons.quiz_outlined,
          color: AppColors.primary,
          size: 32,
        ),
        title: Text(
          quiz.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${quiz.questionCount} questions'
          '${quiz.durationMinutes != null ? ' · ${quiz.durationMinutes} min' : ''}'
          ' · Pass: ${quiz.passScore}%',
        ),
        trailing: quiz.submitted
            ? const Text(
                'View result',
                style: TextStyle(color: AppColors.primary, fontSize: 12),
              )
            : const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => quiz.submitted
                  ? QuizResultScreen(quizId: quiz.id)
                  : QuizTakingScreen(quizId: quiz.id),
            ),
          );
        },
      ),
    );
  }
}

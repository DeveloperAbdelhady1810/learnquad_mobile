import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/arabic_numerals.dart';
import '../../../core/widgets/app_tag.dart';
import '../../../l10n/gen/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return quizzesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) =>
          Center(child: Text(l10n.failedToLoadQuizzes(err.toString()))),
      data: (quizzes) {
        if (quizzes.isEmpty) {
          return Center(child: Text(l10n.noQuizzesYet));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: quizzes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
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
    final fg = Theme.of(context).textTheme.bodyMedium?.color;
    return Material(
      color: Theme.of(context).cardTheme.color,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => quiz.submitted
                  ? QuizResultScreen(quizId: quiz.id)
                  : QuizTakingScreen(quizId: quiz.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.questionsCount(localizedDigits(context, quiz.questionCount)),
                      style: TextStyle(
                        fontSize: 12,
                        color: fg?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              AppTag(
                quiz.submitted
                    ? AppLocalizations.of(context)!.quizSubmitted
                    : AppLocalizations.of(context)!.quizNotStarted,
                variant: quiz.submitted
                    ? AppTagVariant.accent
                    : AppTagVariant.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

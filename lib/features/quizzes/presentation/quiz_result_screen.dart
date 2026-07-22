import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../application/quiz_providers.dart';
import '../data/quiz_models.dart';

class QuizResultScreen extends ConsumerWidget {
  const QuizResultScreen({super.key, required this.quizId});
  final int quizId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(quizResultProvider(quizId));

    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: resultAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(child: Text('Failed to load result: $err')),
        data: (result) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ScoreCard(result: result),
            const Divider(height: 32),
            Text('Answers', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...result.answers.map((a) => _AnswerTile(answer: a)),
          ],
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.result});
  final QuizResult result;

  @override
  Widget build(BuildContext context) {
    final color = result.passed ? AppColors.primary : Colors.red.shade400;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            result.passed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
            size: 48,
            color: color,
          ),
          const SizedBox(height: 12),
          Text(
            result.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${result.percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text('${result.score} / ${result.totalScore} points'),
          const SizedBox(height: 8),
          Text(
            result.passed ? 'Passed' : 'Not passed (need ${result.passScore}%)',
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({required this.answer});
  final QuizAnswerResult answer;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  answer.isCorrect ? Icons.check_circle : Icons.cancel,
                  color: answer.isCorrect
                      ? AppColors.primary
                      : Colors.red.shade400,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    answer.questionText,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Your answer: ${answer.yourAnswer ?? '(none)'}'),
            if (!answer.isCorrect)
              Text('Correct answer: ${answer.correctAnswer}'),
          ],
        ),
      ),
    );
  }
}

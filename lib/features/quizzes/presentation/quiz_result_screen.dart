import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/arabic_numerals.dart';
import '../../../core/widgets/app_tag.dart';
import '../application/quiz_providers.dart';
import '../data/quiz_models.dart';

class QuizResultScreen extends ConsumerWidget {
  const QuizResultScreen({super.key, required this.quizId});
  final int quizId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(quizResultProvider(quizId));

    return Scaffold(
      appBar: AppBar(title: const Text('النتيجة')),
      body: resultAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('تعذّر تحميل النتيجة: $err')),
        data: (result) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
          children: [
            Center(child: _ScoreBadge(result: result)),
            const SizedBox(height: 22),
            Text(
              'الإجابات',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 8),
            ...result.answers.map((a) => _AnswerTile(answer: a)),
          ],
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.result});
  final QuizResult result;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).textTheme.bodyMedium?.color;
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.accent, width: 6),
          ),
          child: Text(
            '${arDigits(result.percentage.round())}٪',
            style: AppTextStyles.brand(size: 32, color: fg),
          ),
        ),
        const SizedBox(height: 16),
        AppTag(
          result.passed ? 'ناجح' : 'راسب',
          variant: result.passed ? AppTagVariant.accent : AppTagVariant.outline,
        ),
        const SizedBox(height: 10),
        Text(
          '${arDigits(result.score)} من ${arDigits(result.totalScore)} إجابات صحيحة',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontSize: 15),
        ),
      ],
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({required this.answer});
  final QuizAnswerResult answer;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).textTheme.bodyMedium?.color;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                answer.isCorrect ? Icons.check_circle : Icons.cancel_outlined,
                color: answer.isCorrect ? AppColors.accent : fg?.withValues(alpha: 0.4),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  answer.questionText,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (!answer.isCorrect) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(right: 26),
              child: Text(
                'إجابتك: ${answer.yourAnswer ?? '(بدون إجابة)'}  ·  الصحيحة: ${answer.correctAnswer}',
                style: TextStyle(fontSize: 11.5, color: fg?.withValues(alpha: 0.65)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

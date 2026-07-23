import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/arabic_numerals.dart';
import '../../../core/widgets/app_tag.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../application/quiz_providers.dart';
import '../data/quiz_models.dart';

class QuizResultScreen extends ConsumerWidget {
  const QuizResultScreen({super.key, required this.quizId});
  final int quizId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(quizResultProvider(quizId));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.resultTitle)),
      body: resultAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text(l10n.failedToLoadResult(err.toString()))),
        data: (result) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
          children: [
            Center(child: _ScoreBadge(result: result)),
            const SizedBox(height: 22),
            Text(
              l10n.answersTitle,
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 6,
            ),
          ),
          child: Text(
            '${localizedDigits(context, result.percentage.round())}٪',
            style: AppTextStyles.brand(context, size: 32, color: fg),
          ),
        ),
        const SizedBox(height: 16),
        AppTag(
          result.passed ? l10n.quizPassed : l10n.quizFailed,
          variant: result.passed ? AppTagVariant.accent : AppTagVariant.outline,
        ),
        const SizedBox(height: 10),
        Text(
          l10n.correctAnswersOf(
            localizedDigits(context, result.score),
            localizedDigits(context, result.totalScore),
          ),
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
    final l10n = AppLocalizations.of(context)!;
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
                color: answer.isCorrect
                    ? Theme.of(context).colorScheme.primary
                    : fg?.withValues(alpha: 0.4),
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
                '${l10n.yourAnswerPrefix}: ${answer.yourAnswer ?? l10n.noAnswer}'
                '  ·  ${l10n.correctAnswerPrefix}: ${answer.correctAnswer}',
                style: TextStyle(fontSize: 11.5, color: fg?.withValues(alpha: 0.65)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

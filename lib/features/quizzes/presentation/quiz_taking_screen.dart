import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/arabic_numerals.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../application/quiz_providers.dart';
import '../data/quiz_models.dart';
import '../data/quiz_repository.dart';
import 'quiz_result_screen.dart';

class QuizTakingScreen extends ConsumerStatefulWidget {
  const QuizTakingScreen({super.key, required this.quizId});
  final int quizId;

  @override
  ConsumerState<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends ConsumerState<QuizTakingScreen> {
  final Map<int, String> _answers = {};
  bool _isSubmitting = false;

  Future<void> _submit(QuizDetail quiz) async {
    final l10n = AppLocalizations.of(context)!;
    final unanswered = quiz.questions.length - _answers.length;
    if (unanswered > 0) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.unansweredQuestionsTitle),
          content: Text(
            l10n.unansweredQuestionsBody(localizedDigits(context, unanswered)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.submit),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(quizRepositoryProvider).submit(widget.quizId, _answers);
      ref.invalidate(quizResultProvider(widget.quizId));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => QuizResultScreen(quizId: widget.quizId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.submitFailed(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizAsync = ref.watch(quizDetailProvider(widget.quizId));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.quizTitleFallback)),
      body: quizAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) {
          // A 409 means the quiz was already submitted — route to the result instead.
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$err'),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => QuizResultScreen(quizId: widget.quizId),
                    ),
                  ),
                  child: Text(l10n.viewResultInstead),
                ),
              ],
            ),
          );
        },
        data: (quiz) => Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.answeredOf(
                      localizedDigits(context, _answers.length),
                      localizedDigits(context, quiz.questions.length),
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: quiz.questions.asMap().entries.map((entry) {
                  return _QuestionCard(
                    index: entry.key + 1,
                    question: entry.value,
                    selected: _answers[entry.value.id],
                    onSelect: (option) =>
                        setState(() => _answers[entry.value.id] = option),
                  );
                }).toList(),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: SafeArea(
                top: false,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _submit(quiz),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.submitAnswers),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.index,
    required this.question,
    required this.selected,
    required this.onSelect,
  });

  final int index;
  final QuizQuestion question;
  final String? selected;
  final void Function(String option) onSelect;

  @override
  Widget build(BuildContext context) {
    final divider = Theme.of(context).dividerColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${localizedDigits(context, index)}. ${question.questionText}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
          ),
          const SizedBox(height: 10),
          ...question.options.entries.map((entry) {
            final isSelected = selected == entry.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: AppRadius.mdBr,
                onTap: () => onSelect(entry.key),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.mdBr,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : divider,
                      width: isSelected ? 2 : 1,
                    ),
                    color: isSelected
                        ? Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.08)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : divider,
                            width: 1.5,
                          ),
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

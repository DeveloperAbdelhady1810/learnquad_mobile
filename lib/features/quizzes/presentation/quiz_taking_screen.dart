import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
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
    final unanswered = quiz.questions.length - _answers.length;
    if (unanswered > 0) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unanswered questions'),
          content: Text(
            'You have $unanswered unanswered question(s). Submit anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Submit'),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to submit: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizAsync = ref.watch(quizDetailProvider(widget.quizId));

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: quizAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
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
                  child: const Text('View result instead'),
                ),
              ],
            ),
          );
        },
        data: (quiz) => Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    quiz.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (quiz.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      quiz.description!,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Pass mark: ${quiz.passScore}%'
                    '${quiz.durationMinutes != null ? ' · ${quiz.durationMinutes} min' : ''}',
                    style: const TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                  const Divider(height: 32),
                  ...quiz.questions.asMap().entries.map(
                    (entry) => _QuestionCard(
                      index: entry.key + 1,
                      question: entry.value,
                      selected: _answers[entry.value.id],
                      onSelect: (option) =>
                          setState(() => _answers[entry.value.id] = option),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
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
                    : Text(
                        'Submit (${_answers.length}/${quiz.questions.length} answered)',
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
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$index. ${question.questionText}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...question.options.entries.map((entry) {
              final isSelected = selected == entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onSelect(entry.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.06)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? AppColors.primary
                              : Colors.black38,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(entry.value)),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/quiz_models.dart';
import '../data/quiz_repository.dart';

final courseQuizzesProvider = FutureProvider.family<List<QuizSummary>, int>((
  ref,
  courseId,
) {
  return ref.watch(quizRepositoryProvider).listForCourse(courseId);
});

final quizDetailProvider = FutureProvider.family<QuizDetail, int>((
  ref,
  quizId,
) {
  return ref.watch(quizRepositoryProvider).detail(quizId);
});

final quizResultProvider = FutureProvider.family<QuizResult, int>((
  ref,
  quizId,
) {
  return ref.watch(quizRepositoryProvider).result(quizId);
});

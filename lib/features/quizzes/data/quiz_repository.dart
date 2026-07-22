import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'quiz_models.dart';

class QuizRepository {
  QuizRepository(this._dio);
  final Dio _dio;

  Future<List<QuizSummary>> listForCourse(int courseId) async {
    final response = await _dio.get('/courses/$courseId/quizzes');
    return (response.data as List)
        .map((q) => QuizSummary.fromJson(q as Map<String, dynamic>))
        .toList();
  }

  Future<QuizDetail> detail(int quizId) async {
    final response = await _dio.get('/quizzes/$quizId');
    return QuizDetail.fromJson(response.data as Map<String, dynamic>);
  }

  /// [answers] maps question id -> chosen option letter (e.g. {12: "B"}).
  Future<void> submit(int quizId, Map<int, String> answers) async {
    await _dio.post(
      '/quizzes/$quizId/submit',
      data: {'answers': answers.map((k, v) => MapEntry(k.toString(), v))},
    );
  }

  Future<QuizResult> result(int quizId) async {
    final response = await _dio.get('/quizzes/$quizId/result');
    return QuizResult.fromJson(response.data as Map<String, dynamic>);
  }
}

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository(ref.watch(apiClientProvider).dio);
});

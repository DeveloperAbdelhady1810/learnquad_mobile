import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'teacher_stats_models.dart';

class TeacherStatsRepository {
  TeacherStatsRepository(this._dio);
  final Dio _dio;

  Future<TeacherStats> stats() async {
    final response = await _dio.get('/teacher/stats');
    return TeacherStats.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<TeacherCourseRow>> courses() async {
    final response = await _dio.get('/teacher/courses');
    return (response.data as List)
        .map((c) => TeacherCourseRow.fromJson(c as Map<String, dynamic>))
        .toList();
  }
}

final teacherStatsRepositoryProvider = Provider<TeacherStatsRepository>((ref) {
  return TeacherStatsRepository(ref.watch(apiClientProvider).dio);
});

final teacherStatsProvider = FutureProvider(
  (ref) => ref.watch(teacherStatsRepositoryProvider).stats(),
);
final teacherCoursesProvider = FutureProvider(
  (ref) => ref.watch(teacherStatsRepositoryProvider).courses(),
);

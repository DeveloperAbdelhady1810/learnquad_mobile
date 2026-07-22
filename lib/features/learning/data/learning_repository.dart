import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../courses/data/course_models.dart';
import 'my_course_models.dart';

class LearningRepository {
  LearningRepository(this._dio);
  final Dio _dio;

  Future<List<MyCourse>> myCourses() async {
    final response = await _dio.get('/my-courses');
    return (response.data as List)
        .map((c) => MyCourse.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/my-courses/{courseId}/lectures returns a plain JSON array of
  /// sections (each with a nested `lectures` array) — reuses the same
  /// [CourseSection]/[CourseLecture] shape as the public course-detail
  /// endpoint (Phase 7), just with completion/progress fields populated.
  Future<List<CourseSection>> lecturesFor(int courseId) async {
    final response = await _dio.get('/my-courses/$courseId/lectures');
    return (response.data as List)
        .map((s) => CourseSection.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  Future<void> markLectureComplete(int lectureId) async {
    await _dio.post('/lectures/$lectureId/complete');
  }
}

final learningRepositoryProvider = Provider<LearningRepository>((ref) {
  return LearningRepository(ref.watch(apiClientProvider).dio);
});

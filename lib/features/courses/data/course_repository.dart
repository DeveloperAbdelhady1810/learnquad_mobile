import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'course_models.dart';

class CourseRepository {
  CourseRepository(this._dio);
  final Dio _dio;

  Future<PaginatedCourses> list({
    int page = 1,
    String? search,
    String? grade,
    String? subject,
  }) async {
    final response = await _dio.get(
      '/courses',
      queryParameters: {
        'page': page,
        if (search != null && search.isNotEmpty) 'search': search,
        if (grade != null && grade.isNotEmpty) 'grade': grade,
        if (subject != null && subject.isNotEmpty) 'subject': subject,
      },
    );
    return PaginatedCourses.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Course> detail(int id) async {
    final response = await _dio.get('/courses/$id');
    return Course.fromJson(response.data as Map<String, dynamic>);
  }
}

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepository(ref.watch(apiClientProvider).dio);
});

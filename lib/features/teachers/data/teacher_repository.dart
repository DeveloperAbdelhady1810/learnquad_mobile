import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'teacher_models.dart';

class TeacherRepository {
  TeacherRepository(this._dio);
  final Dio _dio;

  Future<PaginatedTeachers> list({int page = 1, String? search}) async {
    final response = await _dio.get(
      '/teachers',
      queryParameters: {
        'page': page,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return PaginatedTeachers.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TeacherDetail> detail(int id) async {
    final response = await _dio.get('/teachers/$id');
    return TeacherDetail.fromJson(response.data as Map<String, dynamic>);
  }
}

final teacherRepositoryProvider = Provider<TeacherRepository>((ref) {
  return TeacherRepository(ref.watch(apiClientProvider).dio);
});

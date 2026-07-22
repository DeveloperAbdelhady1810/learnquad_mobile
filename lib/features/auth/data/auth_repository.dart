import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'auth_user.dart';

/// Talks to the Sanctum auth endpoints fixed in Phase 1
/// (POST /api/auth/login, POST /api/auth/register/student,
/// POST /api/auth/logout, GET /api/me).
class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthResult.fromJson(response.data as Map<String, dynamic>);
  }

  /// [grade] and [educationStage] must match the values the web app's
  /// registration form uses (e.g. education_stage: secondary|preparatory,
  /// grade: grade_1|grade_2|grade_3) — see students table + api.php validation.
  Future<AuthResult> registerStudent({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String educationStage,
    required String grade,
    required String gender,
    required int age,
  }) async {
    final response = await _dio.post(
      '/auth/register/student',
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': password,
        'education_stage': educationStage,
        'grade': grade,
        'gender': gender,
        'age': age,
      },
    );
    return AuthResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  Future<AuthUser> me() async {
    final response = await _dio.get('/me');
    return AuthUser.fromJson(response.data as Map<String, dynamic>);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider).dio);
});

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'dashboard_stats.dart';

class DashboardRepository {
  DashboardRepository(this._dio);
  final Dio _dio;

  Future<DashboardStats> stats() async {
    final response = await _dio.get('/dashboard');
    return DashboardStats.fromJson(response.data as Map<String, dynamic>);
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(apiClientProvider).dio);
});

final dashboardStatsProvider = FutureProvider(
  (ref) => ref.watch(dashboardRepositoryProvider).stats(),
);

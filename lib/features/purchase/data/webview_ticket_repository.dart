import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

/// Requests a single-use WebView bridge ticket from
/// POST /api/mobile/webview-ticket (Phase 4). The server resolves and
/// authorizes the exact target URL — this client only supplies an action
/// + id, never a raw URL.
class WebviewTicketRepository {
  WebviewTicketRepository(this._dio);
  final Dio _dio;

  Future<String> requestLearnTicket({
    required int courseId,
    int? lectureId,
  }) async {
    return _requestTicket({
      'action': 'learn',
      'course_id': courseId,
      if (lectureId != null) 'lecture_id': lectureId,
    });
  }

  Future<String> requestPayCourseTicket({required int courseId}) async {
    return _requestTicket({'action': 'pay_course', 'course_id': courseId});
  }

  Future<String> requestPayPackageTicket({required int packageId}) async {
    return _requestTicket({'action': 'pay_package', 'package_id': packageId});
  }

  Future<String> _requestTicket(Map<String, dynamic> data) async {
    final response = await _dio.post('/mobile/webview-ticket', data: data);
    return response.data['bridge_url'] as String;
  }
}

final webviewTicketRepositoryProvider = Provider<WebviewTicketRepository>((
  ref,
) {
  return WebviewTicketRepository(ref.watch(apiClientProvider).dio);
});

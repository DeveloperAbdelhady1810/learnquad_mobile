import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import '../storage/token_store.dart';

/// Thin wrapper around a configured [Dio] instance: injects the Sanctum
/// bearer token on every request, and clears it on a 401 so the router's
/// auth-state check picks up the logout on next navigation.
class ApiClient {
  ApiClient(this.dio, this._tokenStore) {
    dio.options
      ..baseUrl = Env.apiBaseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 15)
      ..headers['Accept'] = 'application/json';

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStore.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _tokenStore.deleteToken();
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio dio;
  final TokenStore _tokenStore;
}

final dioProvider = Provider<Dio>((ref) => Dio());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider), ref.watch(tokenStoreProvider));
});

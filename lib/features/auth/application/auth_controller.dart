import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/storage/token_store.dart';
import '../data/auth_repository.dart';
import '../data/auth_user.dart';

/// Fetches /api/me — also doubles as an end-to-end proof that the stored
/// token actually authenticates against the live API, not just that login
/// itself returned one.
final currentUserProvider = FutureProvider(
  (ref) => ref.watch(authRepositoryProvider).me(),
);

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.isLoading = false,
    this.errorMessage,
    this.user,
  });

  final AuthStatus status;
  final bool isLoading;
  final String? errorMessage;
  final AuthUser? user;

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoading,
    String? errorMessage,
    AuthUser? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _checkToken();
    return const AuthState(status: AuthStatus.unknown);
  }

  TokenStore get _tokenStore => ref.read(tokenStoreProvider);
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<void> _checkToken() async {
    try {
      // iOS Keychain reads (via flutter_secure_storage) can hang or throw on
      // first install / after a re-signing change. Without this timeout and
      // catch, any failure here leaves `status` stuck at `unknown` forever,
      // and the router never routes past the splash screen.
      final token = await _tokenStore.readToken().timeout(
        const Duration(seconds: 5),
      );
      state = AuthState(
        status: token != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
      );
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _repository.login(email: email, password: password);
      await _tokenStore.saveToken(result.token);
      state = AuthState(status: AuthStatus.authenticated, user: result.user);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: Failure.fromDioException(e).message,
      );
      return false;
    }
  }

  Future<bool> registerStudent({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String educationStage,
    required String grade,
    required String gender,
    required int age,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _repository.registerStudent(
        name: name,
        email: email,
        phone: phone,
        password: password,
        educationStage: educationStage,
        grade: grade,
        gender: gender,
        age: age,
      );
      await _tokenStore.saveToken(result.token);
      state = AuthState(status: AuthStatus.authenticated, user: result.user);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: Failure.fromDioException(e).message,
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.logout();
    } catch (_) {
      // Ignore network errors on logout — clear the local token regardless
      // so the user isn't stuck unable to sign out.
    }
    await _tokenStore.deleteToken();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

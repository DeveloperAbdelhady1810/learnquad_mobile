import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps [FlutterSecureStorage] for the Sanctum bearer token — Keychain on
/// iOS, EncryptedSharedPreferences/Keystore on Android. Never store the token
/// in plain SharedPreferences.
class TokenStore {
  TokenStore(this._storage);

  final FlutterSecureStorage _storage;
  static const _tokenKey = 'lq_auth_token';

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> deleteToken() => _storage.delete(key: _tokenKey);
}

final tokenStoreProvider = Provider<TokenStore>((ref) {
  return TokenStore(const FlutterSecureStorage());
});

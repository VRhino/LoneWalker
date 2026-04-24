import 'package:get_storage/get_storage.dart';
import '../constants/storage_keys.dart';

abstract class TokenManager {
  String? get accessToken;
  String? get refreshToken;
  bool get isAuthenticated;

  Future<void> saveTokens(String accessToken, String refreshToken);
  Future<void> saveAccessToken(String token);
  Future<void> clearTokens();

  factory TokenManager() = _GetStorageTokenManager;
}

class _GetStorageTokenManager implements TokenManager {
  final _storage = GetStorage();

  @override
  String? get accessToken => _storage.read(StorageKeys.accessToken);

  @override
  String? get refreshToken => _storage.read(StorageKeys.refreshToken);

  @override
  bool get isAuthenticated => accessToken != null;

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(StorageKeys.accessToken, accessToken);
    await _storage.write(StorageKeys.refreshToken, refreshToken);
  }

  @override
  Future<void> saveAccessToken(String token) async {
    await _storage.write(StorageKeys.accessToken, token);
  }

  @override
  Future<void> clearTokens() async {
    await _storage.remove(StorageKeys.accessToken);
    await _storage.remove(StorageKeys.refreshToken);
  }
}

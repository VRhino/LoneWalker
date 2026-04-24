import 'package:get_storage/get_storage.dart';
import '../constants/storage_keys.dart';

class TokenManager {
  final _storage = GetStorage();

  String? get accessToken => _storage.read(StorageKeys.accessToken);
  String? get refreshToken => _storage.read(StorageKeys.refreshToken);
  bool get isAuthenticated => accessToken != null;

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(StorageKeys.accessToken, accessToken);
    await _storage.write(StorageKeys.refreshToken, refreshToken);
  }

  Future<void> saveAccessToken(String token) async {
    await _storage.write(StorageKeys.accessToken, token);
  }

  Future<void> clearTokens() async {
    await _storage.remove(StorageKeys.accessToken);
    await _storage.remove(StorageKeys.refreshToken);
  }
}

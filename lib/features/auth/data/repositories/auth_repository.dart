import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quvexai_mobile/features/auth/data/datasources/mock_auth_api_data_source.dart';
// UserModel'i import ediyoruz
import 'package:quvexai_mobile/features/auth/data/models/user_model.dart';

class AuthRepository {
  final MockAuthApiDataSource _apiDataSource;

  AuthRepository(this._apiDataSource);

  Future<String> login(String email, String password) async {
    return await _apiDataSource.login(email, password);
  }

  Future<String> register(String email, String password) async {
    return await _apiDataSource.register(email, password);
  }

  Future<void> logout() async {
    await _apiDataSource.logout();
  }

  // --- YENİ FONKSİYON ---
  Future<UserModel> getUserProfile(String token) async {
    return await _apiDataSource.getUserProfile(token);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiDataSource = ref.read(mockAuthApiDataSourceProvider);
  return AuthRepository(apiDataSource);
});

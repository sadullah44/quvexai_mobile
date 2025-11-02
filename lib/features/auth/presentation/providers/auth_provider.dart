// 1. Gerekli paketleri ve dosyaları içe aktarıyoruz
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quvexai_mobile/features/auth/presentation/providers/auth_state.dart';
import 'package:quvexai_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:quvexai_mobile/core/storage/storage_service.dart';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState.initial();
  }

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final token = await ref
          .read(authRepositoryProvider)
          .login(email, password);

      state = state.copyWith(isLoading: false, token: token);
      await ref.read(storageServiceProvider).writeToken(token);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> logout() async {
    await ref.read(storageServiceProvider).deleteToken();

    state = AuthState.initial();
  }
}

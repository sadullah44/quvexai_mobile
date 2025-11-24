import 'package:equatable/equatable.dart';
// 1. Yeni Modelimizi import ediyoruz
import 'package:quvexai_mobile/features/auth/data/models/user_model.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final String? token;

  // 2. YENİ ALAN: Kullanıcı Bilgisi
  // Giriş yapıldığında burası dolacak, çıkışta boşalacak (null).
  final UserModel? user;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.token,
    this.user, // <-- Constructor'a eklendi
  });

  factory AuthState.initial() {
    return const AuthState(
      isLoading: false,
      errorMessage: null,
      token: null,
      user: null, // <-- Başlangıçta kimse yok
    );
  }

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? token,
    UserModel? user, // <-- Güncelleme metoduna eklendi
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          errorMessage, // Hata mesajını temizleyebilmek için null geçilebilir
      token: token ?? this.token,
      user: user ?? this.user, // <-- Değişmezse eskisini koru
    );
  }

  @override
  // 3. Equatable listesine ekliyoruz ki kullanıcı değişirse UI anlasın
  List<Object?> get props => [isLoading, errorMessage, token, user];
}

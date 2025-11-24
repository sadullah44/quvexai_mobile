import 'package:equatable/equatable.dart';

/// Bu sınıf, giriş yapmış kullanıcının bilgilerini tutan kalıptır.
/// API'den gelen JSON verisini Dart nesnesine çevirir.
class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String?
  profileImageUrl; // Profil resmi olmayabilir, o yüzden nullable (?)
  final int totalTestsTaken; // Çözülen test sayısı

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.totalTestsTaken = 0, // Varsayılan olarak 0
  });

  // --- JSON TERCÜMANI ---
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
      // API bazen sayıları farklı formatta yollayabilir, garantiye alalım
      totalTestsTaken: (json['total_tests_taken'] ?? 0) as int,
    );
  }

  // Modeli tekrar JSON'a çevirmek istersek (örn: güncelleme yaparken)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image_url': profileImageUrl,
      'total_tests_taken': totalTestsTaken,
    };
  }

  // Equatable: İki kullanıcının aynı olup olmadığını anlamak için
  @override
  List<Object?> get props => [
    id,
    name,
    email,
    profileImageUrl,
    totalTestsTaken,
  ];
}

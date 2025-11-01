// 1. equatable paketini içe aktarıyoruz (Bunu birazdan ekleyeceğiz)
// Bu, iki state nesnesinin "aynı" olup olmadığını kolayca karşılaştırmamızı sağlar.
// DOĞRU (İki nokta üst üste var)
import 'package:equatable/equatable.dart';

// 2. AuthState sınıfı, kimlik doğrulama durumunun anlık "fotoğrafıdır".
class AuthState extends Equatable {
  // 3. Yükleniyor durumu: API'ye istek giderken true olur.
  //    Arayüz (UI) bunu dinleyerek butonu devre dışı bırakır veya spinner gösterir.
  final bool isLoading;

  // 4. Hata mesajı: Giriş başarısız olursa (örn: "Hatalı şifre"),
  //    bu alanda saklanır. UI bunu dinleyerek snackbar gösterir.
  final String? errorMessage;

  // 5. Token: Giriş başarılı olursa, API'den gelen token burada saklanır.
  //    Eğer 'null' değilse, kullanıcının giriş yapmış olduğunu anlarız.
  final String? token;

  // 6. Constructor (Kurucu Metot): Bu sınıfın nasıl oluşturulacağını tanımlar.
  const AuthState({this.isLoading = false, this.errorMessage, this.token});

  // 7. initial: Durumun "başlangıç" (varsayılan) halini tanımlar.
  //    Uygulama ilk açıldığında durum budur: yüklenmiyor, hata yok, token yok.
  factory AuthState.initial() {
    return const AuthState(isLoading: false, errorMessage: null, token: null);
  }

  // 8. copyWith: Durumu GÜNCELLEMEK için en önemli metottur.
  //    State'i "değiştirmeyiz", bu metotla YENİ BİR KOPYASINI oluştururuz.
  AuthState copyWith({bool? isLoading, String? errorMessage, String? token}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      token: token ?? this.token,
    );
  }

  // 9. Equatable için gerekli: Bu sınıfın hangi alanlara bakarak
  //    "eşit" olduğuna karar vereceğini söyler.
  @override
  List<Object?> get props => [isLoading, errorMessage, token];
}

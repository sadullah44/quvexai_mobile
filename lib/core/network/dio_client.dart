// 1. Gerekli importlar
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quvexai_mobile/core/storage/storage_service.dart';

// -------------------------------------------------------------------
// PARÇA 1: Riverpod "Fabrika" (Provider) Tanımları
// -------------------------------------------------------------------

/// Bu "sağlayıcı", uygulamamızın herhangi bir yerinden ('ref.read' ile)
/// bizim yapılandırılmış, "Token" ekleyebilen 'Dio' istemcimize
/// erişmesini sağlayan "fabrika" tarifidir.
final dioClientProvider = Provider<Dio>((ref) {
  // 1. 'Dio'nun temel bir örneğini (instance) oluştur.
  final dio = Dio(
    BaseOptions(
      // BURAYI KENDİ GERÇEK API ADRESİNİZLE DEĞİŞTİRİN
      baseUrl: 'https://api.sizinprojeniz.com/v1',
      connectTimeout: const Duration(seconds: 10), // Bağlantı zaman aşımı
      receiveTimeout: const Duration(seconds: 10), // Yanıt alma zaman aşımı
    ),
  );

  // 2. "Token Ekleme Denetçisi"ni (Interceptor) oluştur
  // ve 'Dio'ya ekle.
  // 'ref'i (Riverpod aracı) 'AuthInterceptor'a iletiyoruz,
  // çünkü 'AuthInterceptor'ın 'storageServiceProvider'ı okuması gerekecek.
  dio.interceptors.add(AuthInterceptor(ref));

  // 3. Yapılandırılmış 'Dio' istemcisini döndür.
  return dio;
});

// -------------------------------------------------------------------
// PARÇA 2: "Yol Kesici/Denetçi" (Interceptor) Sınıfı
// -------------------------------------------------------------------

/// Bu sınıf, 'Dio'nun yaptığı HER İSTEKTEN hemen önce araya girer ('intercept').
/// Görevi: Giden isteği "denetlemek" ve "Auth Token" eklemektir.
class AuthInterceptor extends Interceptor {
  // 'ref'i (Riverpod aracı) saklamak için bir alan
  final Ref _ref;

  // 'ref'i dışarıdan (constructor ile) alır
  AuthInterceptor(this._ref);

  /// [onRequest] - Bir istek gönderilmeden HEMEN ÖNCE çağrılır.
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 'async' yaptık çünkü token okumak 'await' gerektirir

    // 1. "Depolama Uzmanımızı" (1. Haftada yazdık) Riverpod'dan istiyoruz
    // DİKKAT: 'ref.read' kullanıyoruz, 'ref.watch' DEĞİL!
    // Interceptor gibi yerlerde 'watch' kullanılmaz.
    final storageService = _ref.read(storageServiceProvider);

    // 2. Hafızadan "Auth Token"ı oku
    final token = await storageService.readToken();

    // 3. Token var mı? Varsa, isteğe "ekle".
    if (token != null) {
      // Giden isteğin ('options') 'headers' (başlıklar) bölümüne
      // 'Authorization' (Yetkilendirme) başlığını ekliyoruz.
      // Format genelde 'Bearer [token]' şeklindedir.
      options.headers['Authorization'] = 'Bearer $token';
    }

    // 4. "Devam et":
    // İsteği (belki de token eklenmiş olarak) yoluna devam etmesi
    // için 'handler.next(options)' ile serbest bırakıyoruz.
    return super.onRequest(options, handler);
  }
}

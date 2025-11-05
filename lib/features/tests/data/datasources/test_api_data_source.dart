// 1. Gerekli importlar
import 'package:dio/dio.dart'; // Dio (GET, POST)
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod
import 'package:quvexai_mobile/core/network/dio_client.dart'; // Bizim "Ana Veri Hattımız"
import 'package:quvexai_mobile/features/tests/data/models/test_model.dart'; // Bizim "JSON Tercümanımız"

/// Bu sınıf, 'Test' verisi için *gerçek* API ile konuşan
/// "Veri Kaynağı"dır.
class TestApiDataSource {
  // 2. BAĞIMLILIK:
  // Bu 'Kaynak', çalışmak için 'Dio' (Ana Veri Hattı) istemcisine ihtiyaç duyar.
  final Dio _dio;

  // 3. BAĞIMLILIK ENJEKSİYONU (Constructor):
  // Bu 'Dio' istemcisini dışarıdan alır.
  TestApiDataSource(this._dio);

  /// [getTests] - API'den tüm testlerin listesini çeker.
  Future<List<TestModel>> getTests() async {
    try {
      // 4. ADIM: GERÇEK API ÇAĞRISI
      // "Ana Veri Hattı"nı ('_dio') kullanarak '/tests' endpoint'ine
      // bir GET isteği yap.
      // (Bizim 'AuthInterceptor'ımız bu isteğe 'token'ı otomatik ekleyecek)
      final response = await _dio.get('/tests');

      // 5. ADIM: JSON ÇÖZME (DECODE)
      // Dio, gelen JSON listesini otomatik olarak 'List<dynamic>'
      // (içinde 'Map'ler olan) bir listeye çevirir.
      final List<dynamic> jsonList = response.data as List<dynamic>;

      // 6. ADIM: "TERCÜMAN"I (MODEL) KULLANMA
      // 'jsonList' (çözülmüş liste) üzerinde 'map' (dönüştürme) işlemi yap.
      // Listedeki *her bir* 'json' nesnesini
      // 'TestModel.fromJson' "tercümanına" gönder.
      // Sonuç olarak 'List<TestModel>' (Test Modeli Listesi) elde et.
      return jsonList.map((json) {
        return TestModel.fromJson(json as Map<String, dynamic>);
      }).toList();
    } on DioException catch (e) {
      // 7. ADIM: HATA YÖNETİMİ
      // Eğer 'Dio' (API) bir hata verirse (örn: 404, 500, veya internet yok),
      // bu hatayı yakala ve daha anlaşılır bir hata fırlat.
      print('TestApiDataSource Hata: $e');
      throw Exception('Testler API\'den alınamadı: ${e.message}');
    } catch (e) {
      // Beklenmedik bir hata olursa (örn: JSON 'tercüme' hatası)
      print('TestApiDataSource Bilinmeyen Hata: $e');
      throw Exception('Testler işlenirken bilinmeyen bir hata oluştu: $e');
    }
  }

  // (Buraya gelecekte getTestDetail(String id) fonksiyonu eklenecek)
}

// --- Riverpod Provider ---

/// Bu "sağlayıcı", Riverpod'a TestApiDataSource sınıfını
/// nasıl "inşa edeceğini" (oluşturacağını) öğreten "fabrika" tarifidir.
final testApiDataSourceProvider = Provider<TestApiDataSource>((ref) {
  // 1. ADIM: Bağımlılığı (Ana Veri Hattını) al
  // Riverpod'a "Bana 'dioClientProvider' fabrikasının
  // ürettiği yapılandırılmış 'Dio' istemcisini ver" diyoruz.
  final dio = ref.read(dioClientProvider);

  // 2. ADIM: Veri Kaynağı'nı (DataSource) inşa et
  // Aldığımız 'dio' istemcisini, 'TestApiDataSource'un
  // kurucusuna (constructor) "enjekte ediyoruz".
  return TestApiDataSource(dio);
});

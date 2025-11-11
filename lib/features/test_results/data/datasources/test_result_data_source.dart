// lib/features/test_results/data/datasources/test_result_data_source.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quvexai_mobile/core/network/dio_client.dart'; // Dio provider'ın olduğu dosyaya göre path'ı düzelt
import 'package:quvexai_mobile/features/test_results/data/models/test_result_model.dart';

class TestResultDataSource {
  final Dio _dio;
  TestResultDataSource(this._dio);

  /// Fetch test result for a sessionId
  Future<TestResultModel> fetchTestResult(String sessionId) async {
    try {
      final response = await _dio.get('/test-results/$sessionId');
      // Beklenen 200 ve body JSON
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return TestResultModel.fromJson(data);
        } else {
          // Eğer API liste veya farklı format dönerse, hata fırlat
          throw Exception('Beklenmeyen cevap formatı (test result).');
        }
      } else {
        throw Exception('Sunucu hatası: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // DioError detaylarını loglayıp tekrar fırlat
      throw Exception('Network hatası: ${e.message}');
    } catch (e) {
      throw Exception('Test sonucu alınamadı: $e');
    }
  }
}

// Riverpod provider (fabrika)
final testResultDataSourceProvider = Provider<TestResultDataSource>((ref) {
  final dio = ref.read(dioClientProvider); // daha önce tanımlı dio provider
  return TestResultDataSource(dio);
});

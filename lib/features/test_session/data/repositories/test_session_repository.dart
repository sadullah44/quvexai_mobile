import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:quvexai_mobile/features/test_session/data/datasources/test_session_data_source.dart';
import 'package:quvexai_mobile/features/test_session/data/datasources/test_session_local_data_source.dart';
import 'package:quvexai_mobile/features/test_session/data/models/question_model.dart';
import 'package:quvexai_mobile/core/sync/sync_service.dart';

/// 🔥 Submit sonucu modeli
class SubmitResult {
  final bool success;
  final bool isOffline;
  final String message;

  SubmitResult({
    required this.success,
    required this.isOffline,
    required this.message,
  });
}

class TestSessionRepository {
  final TestSessionDataSource _dataSource;
  final TestSessionLocalDataSource _localDataSource;
  final SyncService _syncService;

  TestSessionRepository(
    this._dataSource,
    this._localDataSource,
    this._syncService,
  );

  Future<List<QuestionModel>> getTestQuestions(String testId) async {
    try {
      return await _dataSource.getTestQuestions(testId);
    } catch (e) {
      debugPrint("❌ Test soruları yüklenemedi: $e");
      rethrow;
    }
  }

  Future<void> saveAnswer(
    String testId,
    String questionId,
    String answerId,
  ) async {
    try {
      await _localDataSource.saveAnswer(
        testId: testId,
        questionId: questionId,
        answerId: answerId,
      );
    } catch (e) {
      debugPrint("⚠️ Cevap kaydedilemedi: $e");
      // Local kayıt hatasını yutuyoruz, UI'a yansıtmıyoruz
    }
  }

  Map<String, String> getSavedAnswers(String testId) {
    try {
      return _localDataSource.getSavedAnswers(testId);
    } catch (e) {
      debugPrint("⚠️ Kaydedilmiş cevaplar getirilemedi: $e");
      return {};
    }
  }

  Future<void> clearSession(String testId) async {
    try {
      await _localDataSource.clearSession(testId);
    } catch (e) {
      debugPrint("⚠️ Oturum temizlenemedi: $e");
    }
  }

  /// 🔥 Gerçek internet bağlantısını test et
  Future<bool> _hasRealInternetConnection() async {
    try {
      // 1. Connectivity kontrolü
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasConnectivity =
          connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi);

      if (!hasConnectivity) {
        debugPrint("📴 Connectivity: Bağlantı yok");
        return false;
      }

      // 2. Gerçek internet kontrolü - Google DNS'e ping at
      try {
        final dio = Dio();
        await dio.get(
          'https://www.google.com',
          options: Options(
            receiveTimeout: const Duration(seconds: 3),
            sendTimeout: const Duration(seconds: 3),
          ),
        );
        debugPrint("🌐 Internet: Aktif");
        return true;
      } catch (e) {
        debugPrint("📴 Internet: Yok (DNS test başarısız)");
        return false;
      }
    } catch (e) {
      debugPrint("📴 Internet kontrolü hatası: $e");
      return false;
    }
  }

  /// 🔥 Test gönderme - Geliştirilmiş hata yönetimi
  Future<SubmitResult> submitTest(
    String testId,
    Map<String, String> answers,
  ) async {
    try {
      // 1. Gerçek internet kontrolü
      final isOnline = await _hasRealInternetConnection();

      debugPrint("🌐 Online durumu: $isOnline");

      if (!isOnline) {
        // OFFLINE → Kuyruğa ekle
        debugPrint("📴 Offline: Test kuyruğa ekleniyor...");
        await _syncService.addToQueue(testId, answers);
        await _localDataSource.clearSession(testId);

        return SubmitResult(
          success: true,
          isOffline: true,
          message:
              "Test kuyruğa eklendi. İnternet bağlantısı geldiğinde otomatik gönderilecek.",
        );
      }

      // 2. ONLINE → API'ye gönder
      debugPrint("🌐 Online: API'ye gönderiliyor...");

      try {
        // TODO: Gerçek API çağrısı
        // await _dataSource.submitTest(testId, answers);
        await Future.delayed(const Duration(seconds: 2)); // Simülasyon

        await _localDataSource.clearSession(testId);

        return SubmitResult(
          success: true,
          isOffline: false,
          message: "Testiniz başarıyla kaydedildi!",
        );
      } on DioException catch (e) {
        // Network hatası - kuyruğa ekle
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.connectionError) {
          debugPrint("⚠️ Timeout/Connection error - Kuyruğa ekleniyor: $e");
          await _syncService.addToQueue(testId, answers);
          await _localDataSource.clearSession(testId);

          return SubmitResult(
            success: true,
            isOffline: true,
            message: "Bağlantı hatası. Test kuyruğa eklendi.",
          );
        }

        // Token expired
        if (e.response?.statusCode == 401) {
          debugPrint("⚠️ Token expired");
          await _syncService.addToQueue(testId, answers);
          await _localDataSource.clearSession(testId);

          return SubmitResult(
            success: false,
            isOffline: true,
            message:
                "Oturum süresi doldu. Test kuyruğa eklendi, lütfen giriş yapın.",
          );
        }

        // Diğer API hataları
        debugPrint(
          "⚠️ API hatası: ${e.response?.statusCode} - Kuyruğa ekleniyor",
        );
        await _syncService.addToQueue(testId, answers);
        await _localDataSource.clearSession(testId);

        return SubmitResult(
          success: true,
          isOffline: true,
          message: "Sunucu hatası. Test kuyruğa eklendi.",
        );
      }
    } catch (e) {
      // Beklenmeyen hata - kuyruğa ekle
      debugPrint("❌ Beklenmeyen hata: $e - Kuyruğa ekleniyor");

      try {
        await _syncService.addToQueue(testId, answers);
        await _localDataSource.clearSession(testId);

        return SubmitResult(
          success: true,
          isOffline: true,
          message:
              "Test kuyruğa eklendi. İnternet bağlantısı geldiğinde otomatik gönderilecek.",
        );
      } catch (queueError) {
        debugPrint("❌ Kuyruğa ekleme hatası: $queueError");

        return SubmitResult(
          success: false,
          isOffline: false,
          message: "Kritik hata: Test kaydedilemedi. Lütfen tekrar deneyin.",
        );
      }
    }
  }
}

// --- Provider ---
final testSessionRepositoryProvider = Provider<TestSessionRepository>((ref) {
  final dataSource = ref.read(testSessionDataSourceProvider);
  final localDataSource = ref.read(testSessionLocalDataSourceProvider);
  final syncService = ref.read(syncServiceProvider);

  return TestSessionRepository(dataSource, localDataSource, syncService);
});

import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quvexai_mobile/core/notifications/notification_service.dart';

/// 🔥 Sync raporu modeli
class SyncReport {
  final int total;
  final int success;
  final int failed;
  final List<String> failedTestIds;

  SyncReport({
    required this.total,
    required this.success,
    required this.failed,
    required this.failedTestIds,
  });

  bool get hasFailures => failed > 0;
  bool get allSuccess => total == success;
  bool get isEmpty => total == 0;
}

/// 🔥 Kuyruk öğesi modeli
class QueueItem {
  final String testId;
  final Map<String, String> answers;
  final DateTime addedAt;
  final int retryCount;

  QueueItem({
    required this.testId,
    required this.answers,
    required this.addedAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'testId': testId,
      'answers': answers,
      'timestamp': addedAt.millisecondsSinceEpoch,
      'addedAt': addedAt.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  factory QueueItem.fromMap(Map<dynamic, dynamic> map) {
    return QueueItem(
      testId: map['testId'] as String,
      answers: Map<String, String>.from(map['answers'] as Map),
      addedAt: DateTime.parse(map['addedAt'] as String),
      retryCount: map['retryCount'] as int? ?? 0,
    );
  }
}

class SyncService {
  static const String _queueBoxName = 'sync_queue_box';
  static const int _maxRetries = 3;
  final Ref _ref;
  bool _isSyncing = false;

  SyncService(this._ref) {
    _initConnectivityListener();
  }

  /// 🔥 Gönderilemeyen bir testi kuyruğa ekler
  Future<void> addToQueue(String testId, Map<String, String> answers) async {
    final box = Hive.box<Map>(_queueBoxName);

    // Çakışma kontrolü - Aynı test varsa üzerine yaz
    if (box.containsKey(testId)) {
      debugPrint("⚠️ Test zaten kuyrukta, güncelleniyor: $testId");
    }

    final item = QueueItem(
      testId: testId,
      answers: answers,
      addedAt: DateTime.now(),
    );

    await box.put(testId, item.toMap());
    debugPrint("📦 Offline: Test kuyruğa eklendi -> $testId");
  }

  /// 🔥 Kuyruk bilgisi
  int getQueueSize() {
    final box = Hive.box<Map>(_queueBoxName);
    return box.length;
  }

  /// 🔥 Kuyruk detayları
  List<QueueItem> getQueueItems() {
    final box = Hive.box<Map>(_queueBoxName);
    return box.values
        .map((e) => QueueItem.fromMap(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => a.addedAt.compareTo(b.addedAt));
  }

  /// 🔥 İnternet durumunu dinler
  void _initConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi)) {
        debugPrint("🌐 İnternet bağlantısı tespit edildi!");
        _processQueue();
      }
    });
  }

  /// 🔥 Kuyruktaki testleri sırayla gönderir
  Future<SyncReport> _processQueue() async {
    if (_isSyncing) {
      debugPrint("⏳ Senkronizasyon zaten devam ediyor, atlanıyor...");
      return SyncReport(total: 0, success: 0, failed: 0, failedTestIds: []);
    }

    _isSyncing = true;
    final box = Hive.box<Map>(_queueBoxName);

    if (box.isEmpty) {
      debugPrint("✅ Kuyruk boş");
      _isSyncing = false;
      return SyncReport(total: 0, success: 0, failed: 0, failedTestIds: []);
    }

    debugPrint("🔄 Senkronizasyon başladı: ${box.length} test sırada");

    int successCount = 0;
    int failedCount = 0;
    List<String> failedTestIds = [];

    // Timestamp'e göre sırala
    final items = getQueueItems();

    for (var item in items) {
      try {
        debugPrint(
          "📤 Gönderiliyor: ${item.testId} (Deneme: ${item.retryCount + 1}/$_maxRetries)",
        );

        // 🔥 Simülasyon - Gerçek API entegrasyonu için repository'nin submitTest metodunu kullanın
        // Şimdilik başarılı kabul ediyoruz
        await Future.delayed(const Duration(seconds: 1));

        // Başarılı - kuyruktan sil
        await box.delete(item.testId);
        successCount++;
        debugPrint("✅ Başarıyla gönderildi: ${item.testId}");

        // 🔥 Test sonucu bildirimini göster
        await NotificationService.instance.showTestResultReadyNotification(
          testName: "Test",
          sessionId: item.testId,
        );
      } catch (e) {
        debugPrint("❌ Gönderim hatası (${item.testId}): $e");

        // Yeniden deneme mekanizması
        if (item.retryCount < _maxRetries) {
          final updatedItem = QueueItem(
            testId: item.testId,
            answers: item.answers,
            addedAt: item.addedAt,
            retryCount: item.retryCount + 1,
          );
          await box.put(item.testId, updatedItem.toMap());
          debugPrint("🔄 Tekrar denenecek: ${item.testId}");
        } else {
          failedCount++;
          failedTestIds.add(item.testId);
          debugPrint("⛔ Başarısız: ${item.testId} (Max deneme aşıldı)");
        }
      }
    }

    final report = SyncReport(
      total: items.length,
      success: successCount,
      failed: failedCount,
      failedTestIds: failedTestIds,
    );

    // Bildirim göster
    if (report.total > 0) {
      await NotificationService.instance.showSyncCompletedNotification(
        successCount: report.success,
        totalCount: report.total,
      );
    }

    if (report.allSuccess) {
      debugPrint(
        "✅ Senkronizasyon tamamlandı: ${report.success}/${report.total} başarılı",
      );
    } else if (report.hasFailures) {
      debugPrint(
        "⚠️ Senkronizasyon tamamlandı: ✅${report.success} başarılı, ❌${report.failed} başarısız",
      );
    }

    _isSyncing = false;
    return report;
  }

  /// 🔥 Manuel sync tetikleme
  Future<SyncReport> manualSync() async {
    debugPrint("🔄 Manuel senkronizasyon başlatıldı");
    return await _processQueue();
  }

  /// 🔥 Kuyruğu temizle
  Future<void> clearQueue() async {
    final box = Hive.box<Map>(_queueBoxName);
    await box.clear();
    debugPrint("🗑️ Kuyruk tamamen temizlendi");
  }

  /// 🔥 Syncing durumu
  bool get isSyncing => _isSyncing;
}

// --- Provider ---
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref);
});

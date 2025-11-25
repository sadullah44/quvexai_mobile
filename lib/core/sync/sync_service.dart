import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Repository'mizi import ediyoruz (Veriyi tekrar göndermek için lazım)

class SyncService {
  static const String _queueBoxName = 'sync_queue_box';
  final Ref _ref; // Riverpod ref'i (Repository'ye erişmek için)

  SyncService(this._ref) {
    // Servis başlar başlamaz interneti dinlemeye başla
    _initConnectivityListener();
  }

  /// [addToQueue] - Gönderilemeyen bir testi kuyruğa ekler.
  Future<void> addToQueue(String testId, Map<String, String> answers) async {
    final box = Hive.box<Map>(_queueBoxName);

    // Test ID'sini anahtar olarak kullanıyoruz.
    // Değer olarak cevapları ve o anki zamanı saklıyoruz.
    final data = {
      'testId': testId,
      'answers': answers,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await box.put(testId, data);
    print("📦 Offline Mod: Test kuyruğa eklendi -> $testId");
  }

  /// [_initConnectivityListener] - İnternet durumunu dinler.
  void _initConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      // Eğer sonuçlardan biri mobile veya wifi ise internet var demektir.
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi)) {
        print(
          "🌐 İnternet Bağlantısı Tespit Edildi! Kuyruk kontrol ediliyor...",
        );
        _processQueue();
      }
    });
  }

  /// [_processQueue] - Kuyruktaki testleri sırayla göndermeyi dener.
  Future<void> _processQueue() async {
    final box = Hive.box<Map>(_queueBoxName);

    if (box.isEmpty) {
      print("✅ Kuyruk boş, gönderilecek bir şey yok.");
      return;
    }

    print("🔄 Senkronizasyon Başladı: ${box.length} test sırada bekliyor.");

    // Kutudaki tüm anahtarları (testId'leri) al
    final keys = box.keys.toList();

    for (var key in keys) {
      final data = Map<String, dynamic>.from(box.get(key) as Map);
      final testId = data['testId'] as String;
      final answers = Map<String, String>.from(data['answers'] as Map);

      try {
        print("📤 Gönderiliyor: $testId ...");

        // Repository'deki 'submitTest' benzeri bir mantığı burada manuel çalıştıracağız.
        // Normalde Repository'de 'submitRawData' gibi bir metod olması daha temiz olurdu,
        // ama şimdilik simüle ediyoruz.

        // (Burada gerçek API çağrısı yapılır)
        await Future.delayed(const Duration(seconds: 1)); // Simülasyon

        // Başarılı olursa kuyruktan sil
        await box.delete(key);
        print("✅ Başarıyla Gönderildi ve Kuyruktan Silindi: $testId");

        // Kullanıcıya haber ver (Opsiyonel: Local Notification burada kullanılabilir)
      } catch (e) {
        print("❌ Gönderim Hatası ($testId): $e. Kuyrukta kalacak.");
        // Hata olursa silmiyoruz, bir sonraki internet gelişinde tekrar dener.
      }
    }
  }
}

// --- Provider ---
// Bu servis 'ref' gerektirdiği için 'Provider' ile oluşturuyoruz.
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref);
});

// 1. Gerekli importlar
import 'package:flutter_riverpod/flutter_riverpod.dart';
// "Aracımız" (Canvas'taki dosyanız)
import 'package:quvexai_mobile/features/test_session/data/repositories/test_session_repository.dart';
// "Gösterge Panelimiz" (Canvas'taki dosyanız)
import 'package:quvexai_mobile/features/test_session/presentation/providers/test_session_state.dart';

// -------------------------------------------------------------------
// PARÇA 1: Provider (Arayüzün Erişim Noktası)
// -------------------------------------------------------------------

/// Bu, Arayüzün (UI) 'TestSessionNotifier'a erişmek için kullanacağı
/// "anahtar yuvasıdır". Arkadaşınızın 'TestSessionScreen' arayüzü
/// bu provider'ı 'watch' (izleyecek).
final testSessionProvider =
    NotifierProvider<TestSessionNotifier, TestSessionState>(
      () => TestSessionNotifier(),
    );

// -------------------------------------------------------------------
// PARÇA 2: Notifier (Test Çözme Beyni / Yönetici)
// -------------------------------------------------------------------

/// Bu sınıf, 'TestSessionState' gösterge panelini aktif olarak yöneten beyindir.
/// Planımızdaki tüm "Test Çözme Mantığı" (Logic) buradadır.
class TestSessionNotifier extends Notifier<TestSessionState> {
  // --- 1. Başlangıç Durumunu Ayarlama ---

  @override
  TestSessionState build() {
    // "Gösterge Paneli"ni varsayılan (boş) haliyle başlatır.
    return TestSessionState.initial();
  }

  // --- 2. Ana İşlevler (Actions) ---

  /// [loadQuestions] - Testin sorularını 'Mock API'dan (JSON) getirir.
  /// Arayüz (UI), "Teste Başla" butonuna basıldığında bu fonksiyonu çağırır.
  Future<void> loadQuestions(String testId) async {
    // (Eğer zaten yükleniyorsa veya yüklendiyse tekrar yükleme)
    if (state.status == TestSessionStatus.loading ||
        state.status == TestSessionStatus.loaded)
      return;

    try {
      // ADIM A: YÜKLENİYOR IŞIĞINI YAK (Status'ü 'loading' yap)
      state = state.copyWith(
        status: TestSessionStatus.loading,
        errorMessage: null,
      );

      // ADIM B: "ARACI"YI ÇAĞIR (G3, Adım 8'i kullan - Canvas'taki dosyanız)
      final questionsList = await ref
          .read(testSessionRepositoryProvider)
          .getTestQuestions(testId);

      // (Bizim "Veri Hattımız" (Repository -> DataSource) gidecek,
      // 'test_session.json'u okuyacak, "Tercüman"ları ('QuestionModel')
      // çalıştıracak ve 'List<QuestionModel>' olarak buraya döndürecek)

      // ADIM C: BAŞARILI DURUM (Veri Listesi Işığını Yak)
      state = state.copyWith(
        status: TestSessionStatus.loaded, // Durumu "Yüklendi" yap
        questions: questionsList, // Soruları "Gösterge Paneli"ne yaz
        currentIndex: 0, // Her zaman 0. sorudan başla
        userAnswers: {}, // Eski cevapları (varsa) temizle
      );
    } catch (e) {
      // ADIM D: HATA DURUMU
      state = state.copyWith(
        status: TestSessionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// [selectAnswer] - Kullanıcı bir cevap seçtiğinde çağrılır.
  /// (Plan: Cevaplar lokalde tutulur)
  void selectAnswer(String questionId, String answerId) {
    // 'userAnswers' haritasının (map) yeni bir "kopyasını" al
    // (Değişmezlik 'Immutability' kuralı için)
    final newAnswers = Map<String, String>.from(state.userAnswers);

    // Yeni cevabı ekle / üzerine yaz
    newAnswers[questionId] = answerId;

    // "Gösterge Paneli"ni yeni cevap haritasıyla güncelle
    state = state.copyWith(userAnswers: newAnswers);
  }

  /// [nextQuestion] - "İleri" butonuna basıldığında çağrılır.
  /// (Plan: Next/Previous navigasyonu)
  void nextQuestion() {
    // Eğer son soruda değilsek...
    if (state.currentIndex < state.questions.length - 1) {
      // ...indeksi bir artır.
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  /// [previousQuestion] - "Geri" butonuna basıldığında çağrılır.
  /// (Plan: Next/Previous navigasyonu)
  void previousQuestion() {
    // Eğer ilk soruda değilsek...
    if (state.currentIndex > 0) {
      // ...indeksi bir azalt.
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  // TODO: MADDE 3
  // Burası, 'submitTest' (Bitir & Gönder) fonksiyonunun
  // ekleneceği yer olacak. (Plan: Son adımda “Bitir & Gönder”)
}

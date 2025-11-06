// 1. Gerekli importlar
import 'package:equatable/equatable.dart';
// Canvas'taki "Soru Tercümanı"mızı (Model) import ediyoruz
import 'package:quvexai_mobile/features/test_session/data/models/question_model.dart';

// 2. Enum: Yükleme durumlarını daha net yönetmek için
enum TestSessionStatus { initial, loading, loaded, submitting, finished, error }

/// Bu sınıf, "Test Çözme" özelliğinin anlık "fotoğrafıdır".
/// Arayüz (UI), bu duruma ('State') bakarak ne çizeceğine karar verir.
class TestSessionState extends Equatable {
  // 3. Durum (Enum): 'isLoading' (bool) yerine daha detaylı bir durum
  //    (örn: 'submitting' - 'Cevaplar Gönderiliyor')
  final TestSessionStatus status;

  // 4. Hata mesajı
  final String? errorMessage;

  // 5. O anki testin tüm soruları
  final List<QuestionModel> questions;

  // 6. Kullanıcının verdiği cevaplar
  //    (Soru ID'sini Cevap ID'sine eşleyen bir "Harita")
  final Map<String, String> userAnswers;

  // 7. Kullanıcının o anda gördüğü sorunun indeksi
  final int currentIndex;

  // 8. Standart Kurucu (Constructor)
  const TestSessionState({
    required this.status,
    this.errorMessage,
    required this.questions,
    required this.userAnswers,
    required this.currentIndex,
  });

  // 9. initial: Durumun "başlangıç" (varsayılan) halini tanımlar.
  factory TestSessionState.initial() {
    return const TestSessionState(
      status: TestSessionStatus.initial, // Başlangıçta
      errorMessage: null,
      questions: [], // Soru listesi boş
      userAnswers: {}, // Cevap haritası boş
      currentIndex: 0, // İlk sorudan başla
    );
  }

  // 10. copyWith: Durumu GÜNCELLEMEK için (Değişmezlik kuralı)
  //     "Beyin" ('TestSessionNotifier'), bu metodu
  //     kullanarak yeni 'state' kopyaları oluşturur.
  TestSessionState copyWith({
    TestSessionStatus? status,
    String? errorMessage,
    List<QuestionModel>? questions,
    Map<String, String>? userAnswers,
    int? currentIndex,
  }) {
    return TestSessionState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      questions: questions ?? this.questions,
      userAnswers: userAnswers ?? this.userAnswers,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  // 11. Equatable için gerekli (props listesi)
  @override
  List<Object?> get props => [
    status,
    errorMessage,
    questions,
    userAnswers,
    currentIndex,
  ];
}

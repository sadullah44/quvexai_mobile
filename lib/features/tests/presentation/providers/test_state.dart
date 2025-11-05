// 1. Gerekli importlar
import 'package:equatable/equatable.dart'; // Karşılaştırma için
import 'package:quvexai_mobile/features/tests/data/models/test_model.dart'; // "JSON Tercümanımız"

/// Bu sınıf, "Testler" özelliğinin anlık "fotoğrafıdır".
/// Arayüz (UI), bu duruma ('State') bakarak ne çizeceğine karar verir.
class TestState extends Equatable {
  // 2. Yükleniyor durumu: API'den veriler çekilirken true olur.
  //    Arayüz (UI) bunu dinleyerek 'Skeleton Loader' gösterir.
  final bool isLoading;

  // 3. Hata mesajı: API'den veri çekme başarısız olursa
  //    bu alanda saklanır. UI bunu dinleyerek hata mesajı gösterir.
  final String? errorMessage;

  // 4. EN ÖNEMLİ ALAN: Testlerin Listesi
  //    API'den başarıyla okunan 'TestModel' listesi
  //    burada saklanır. UI bu listeyi alıp 'ListView'de çizer.
  final List<TestModel> tests;

  // 5. Standart Kurucu (Constructor)
  const TestState({
    required this.isLoading,
    this.errorMessage,
    required this.tests,
  });

  // 6. initial: Durumun "başlangıç" (varsayılan) halini tanımlar.
  //    Uygulama ilk açıldığında durum budur:
  //    yüklenmiyor, hata yok, test listesi boş.
  factory TestState.initial() {
    return const TestState(
      isLoading: false,
      errorMessage: null,
      tests: [], // Başlangıçta liste boştur
    );
  }

  // 7. copyWith: Durumu GÜNCELLEMEK için (Değişmezlik kuralı)
  //    'TestNotifier' (Beyin), bu metodu
  //    kullanarak yeni 'state' kopyaları oluşturur.
  TestState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<TestModel>? tests,
  }) {
    return TestState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      tests: tests ?? this.tests,
    );
  }

  // 8. Equatable için gerekli (props listesi)
  @override
  List<Object?> get props => [isLoading, errorMessage, tests];
}

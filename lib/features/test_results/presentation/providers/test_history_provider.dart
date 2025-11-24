import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quvexai_mobile/features/test_results/data/models/test_result_model.dart';
import 'package:quvexai_mobile/features/test_results/data/repositories/test_result_repository.dart';

// Sıralama seçenekleri için bir Enum
enum SortOption { dateNewest, dateOldest, scoreHigh, scoreLow }

// --- STATE (Gösterge Paneli) ---
class TestHistoryState {
  final bool isLoading;

  // 1. Ana Depo: Tüm veriler burada durur.
  final List<TestResultModel> allHistory;

  // 2. Vitrin: Ekranda sadece burası gösterilir (Filtrelenmiş).
  final List<TestResultModel> filteredHistory;

  final SortOption currentSort;

  TestHistoryState({
    this.isLoading = false,
    this.allHistory = const [],
    this.filteredHistory = const [],
    this.currentSort = SortOption.dateNewest,
  });

  // State kopyalama metodu
  TestHistoryState copyWith({
    bool? isLoading,
    List<TestResultModel>? allHistory,
    List<TestResultModel>? filteredHistory,
    SortOption? currentSort,
  }) {
    return TestHistoryState(
      isLoading: isLoading ?? this.isLoading,
      allHistory: allHistory ?? this.allHistory,
      filteredHistory: filteredHistory ?? this.filteredHistory,
      currentSort: currentSort ?? this.currentSort,
    );
  }
}

// --- NOTIFIER (Beyin) ---
class TestHistoryNotifier extends Notifier<TestHistoryState> {
  @override
  TestHistoryState build() {
    return TestHistoryState();
  }

  /// [loadHistory] - Tüm geçmişi yükler.
  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);

    try {
      // Aracıdan veriyi çek (API veya Hive)
      final history = await ref
          .read(testResultRepositoryProvider)
          .getTestHistory();

      // Varsayılan sıralamayı (En yeni tarih) uygula.
      _sortList(history, SortOption.dateNewest);

      state = TestHistoryState(
        isLoading: false,
        allHistory: history,
        filteredHistory: history, // Başlangıçta hepsi görünür
        currentSort: SortOption.dateNewest,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// [search] - Test adına, ID'sine veya yoruma göre arama yapar.
  void search(String query) {
    if (query.isEmpty) {
      // Arama kutusu boşsa, her şeyi göster (Mevcut sıralamayı koruyarak)
      final list = List<TestResultModel>.from(state.allHistory);
      _sortList(list, state.currentSort);
      state = state.copyWith(filteredHistory: list);
      return;
    }

    // Ana depoda arama yap
    final filtered = state.allHistory.where((result) {
      final searchLower = query.toLowerCase();

      // --- GÜNCELLEME: ARTIK TEST ADINA DA BAKIYORUZ ---
      return result.testName.toLowerCase().contains(
            searchLower,
          ) || // Başlıkta ara
          result.sessionId.toLowerCase().contains(searchLower) || // ID'de ara
          result.feedback.toLowerCase().contains(searchLower); // Yorumda ara
    }).toList();

    // Bulunanları da mevcut düzene göre sırala
    _sortList(filtered, state.currentSort);

    state = state.copyWith(filteredHistory: filtered);
  }

  /// [sort] - Listeyi sıralar.
  void sort(SortOption option) {
    // Şu an vitrindeki listeyi al (arama yapılmış olabilir)
    final currentList = List<TestResultModel>.from(state.filteredHistory);

    // Sırala
    _sortList(currentList, option);

    // Güncelle
    state = state.copyWith(filteredHistory: currentList, currentSort: option);
  }

  // Yardımcı Sıralama Fonksiyonu
  void _sortList(List<TestResultModel> list, SortOption option) {
    switch (option) {
      case SortOption.dateNewest:
        list.sort((a, b) => b.completedAt.compareTo(a.completedAt));
        break;
      case SortOption.dateOldest:
        list.sort((a, b) => a.completedAt.compareTo(b.completedAt));
        break;
      case SortOption.scoreHigh:
        list.sort((a, b) => b.totalScore.compareTo(a.totalScore));
        break;
      case SortOption.scoreLow:
        list.sort((a, b) => a.totalScore.compareTo(b.totalScore));
        break;
    }
  }
}

// --- PROVIDER ---
final testHistoryProvider =
    NotifierProvider<TestHistoryNotifier, TestHistoryState>(() {
      return TestHistoryNotifier();
    });

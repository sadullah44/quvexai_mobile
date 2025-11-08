import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quvexai_mobile/features/test_results/data/models/test_result_model.dart';
import 'package:quvexai_mobile/features/test_results/data/repositories/test_result_repository.dart';

// --- STATE (GÖSTERGE PANELİ) ---
class TestHistoryState {
  final bool isLoading;
  final List<TestResultModel> history;

  TestHistoryState({this.isLoading = false, this.history = const []});
}

// --- NOTIFIER (BEYİN) ---
class TestHistoryNotifier extends Notifier<TestHistoryState> {
  @override
  TestHistoryState build() {
    return TestHistoryState(isLoading: false, history: []);
  }

  /// Geçmişi yükle
  Future<void> loadHistory() async {
    // 1. Yükleniyor ışığını yak
    state = TestHistoryState(isLoading: true, history: state.history);

    // 2. Aracıdan veriyi iste
    final historyList = await ref
        .read(testResultRepositoryProvider)
        .getTestHistory();

    // 3. Sonucu panele yaz, ışığı söndür
    state = TestHistoryState(isLoading: false, history: historyList);
  }
}

// --- PROVIDER (FİŞ) ---
final testHistoryProvider =
    NotifierProvider<TestHistoryNotifier, TestHistoryState>(() {
      return TestHistoryNotifier();
    });

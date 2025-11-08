import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/test_result_model.dart';
import '../../data/repositories/test_result_repository.dart';

// --- STATE (Gösterge Paneli) ---
class TestResultState {
  final bool isLoading;
  final TestResultModel? result;
  final String? errorMessage;

  TestResultState({this.isLoading = false, this.result, this.errorMessage});

  factory TestResultState.initial() => TestResultState(isLoading: false);

  TestResultState copyWith({
    bool? isLoading,
    TestResultModel? result,
    String? errorMessage,
  }) {
    return TestResultState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage:
          errorMessage, // Hata mesajını null geçebilmek için '?? this.errorMessage' yapmadık
    );
  }
}

// --- NOTIFIER (Beyin) ---
class TestResultNotifier extends StateNotifier<TestResultState> {
  final TestResultRepository _repository;

  TestResultNotifier(this._repository) : super(TestResultState.initial());

  Future<void> fetchResult(String sessionId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // İŞTE SİHİRLİ SATIR BURASI!
      // Bu çağrı yapıldığında Repository hem API'den çekecek HEM DE Hive'a kaydedecek.
      final result = await _repository.getResult(sessionId);

      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

// --- PROVIDER (Fabrika) ---
final testResultProvider =
    StateNotifierProvider<TestResultNotifier, TestResultState>((ref) {
      final repo = ref.read(testResultRepositoryProvider);
      return TestResultNotifier(repo);
    });

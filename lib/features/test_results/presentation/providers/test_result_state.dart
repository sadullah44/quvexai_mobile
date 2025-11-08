import 'package:equatable/equatable.dart';
import 'package:quvexai_mobile/features/test_results/data/models/test_result_model.dart'; // Modelimizi import ediyoruz

/// Bu sınıf, Test Sonucu ekranının anlık durumunu tutar.
class TestResultState extends Equatable {
  final bool isLoading; // Veri yükleniyor mu?
  final String? errorMessage; // Hata mesajı
  final TestResultModel? result; // Test sonucu verisi

  const TestResultState({
    required this.isLoading,
    this.errorMessage,
    this.result,
  });

  // Başlangıç durumu
  factory TestResultState.initial() {
    return const TestResultState(
      isLoading: false,
      errorMessage: null,
      result: null,
    );
  }

  // Durumu güncellemek için copyWith
  TestResultState copyWith({
    bool? isLoading,
    String? errorMessage,
    TestResultModel? result,
  }) {
    return TestResultState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, result];
}

// lib/features/tests/presentation/providers/test_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quvexai_mobile/features/tests/data/datasources/mock_test_data_source.dart';
import 'package:quvexai_mobile/features/tests/data/models/test_model.dart';

class TestState {
  final bool isLoading;
  final List<TestModel> tests;
  final String? errorMessage;

  TestState({required this.isLoading, required this.tests, this.errorMessage});

  factory TestState.initial() =>
      TestState(isLoading: false, tests: [], errorMessage: null);

  TestState copyWith({
    bool? isLoading,
    List<TestModel>? tests,
    String? errorMessage,
  }) {
    return TestState(
      isLoading: isLoading ?? this.isLoading,
      tests: tests ?? this.tests,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class TestNotifier extends StateNotifier<TestState> {
  final TestApiDataSource dataSource;

  TestNotifier(this.dataSource) : super(TestState.initial());

  Future<void> fetchTests() async {
    state = state.copyWith(isLoading: true);
    try {
      final tests = await dataSource.getTests();
      state = state.copyWith(isLoading: false, tests: tests);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final testProvider = StateNotifierProvider<TestNotifier, TestState>(
  (ref) => TestNotifier(TestApiDataSource()),
);

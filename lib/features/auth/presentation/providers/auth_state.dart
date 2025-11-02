import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final bool isLoading;

  final String? errorMessage;

  final String? token;

  const AuthState({this.isLoading = false, this.errorMessage, this.token});

  factory AuthState.initial() {
    return const AuthState(isLoading: false, errorMessage: null, token: null);
  }

  AuthState copyWith({bool? isLoading, String? errorMessage, String? token}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, token];
}

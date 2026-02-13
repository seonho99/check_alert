import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_in_state.freezed.dart';

@freezed
class SignInState with _$SignInState {
  const SignInState({
    @override required this.email,
    @override required this.password,
    @override required this.isLoading,
    @override required this.obscurePassword,
    @override required this.isLoginSuccess,
    @override this.errorMessage,
    @override this.successMessage,
  });

  @override
  final String email;
  @override
  final String password;
  @override
  final bool isLoading;
  @override
  final bool obscurePassword;
  @override
  final bool isLoginSuccess;
  @override
  final String? errorMessage;
  @override
  final String? successMessage;

  factory SignInState.initial() => const SignInState(
        email: '',
        password: '',
        isLoading: false,
        obscurePassword: true,
        isLoginSuccess: false,
      );
}

extension SignInStateExtension on SignInState {
  bool get isValid => email.isNotEmpty && password.isNotEmpty;
  bool get hasError => errorMessage != null;
}

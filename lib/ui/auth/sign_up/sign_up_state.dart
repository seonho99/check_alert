import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_state.freezed.dart';

@freezed
class SignUpState with _$SignUpState {
  const SignUpState({
    @override required this.email,
    @override required this.password,
    @override required this.confirmPassword,
    @override required this.displayName,
    @override required this.isLoading,
    @override required this.obscurePassword,
    @override required this.obscureConfirmPassword,
    @override required this.isSignUpSuccess,
    @override this.errorMessage,
    @override this.successMessage,
  });

  @override
  final String email;
  @override
  final String password;
  @override
  final String confirmPassword;
  @override
  final String displayName;
  @override
  final bool isLoading;
  @override
  final bool obscurePassword;
  @override
  final bool obscureConfirmPassword;
  @override
  final bool isSignUpSuccess;
  @override
  final String? errorMessage;
  @override
  final String? successMessage;

  factory SignUpState.initial() => const SignUpState(
        email: '',
        password: '',
        confirmPassword: '',
        displayName: '',
        isLoading: false,
        obscurePassword: true,
        obscureConfirmPassword: true,
        isSignUpSuccess: false,
      );
}

extension SignUpStateExtension on SignUpState {
  bool get isValid =>
      email.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty;
  bool get hasError => errorMessage != null;
}

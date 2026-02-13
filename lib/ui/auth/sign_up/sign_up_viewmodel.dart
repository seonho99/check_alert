import 'package:flutter/material.dart';

import '../../../domain/usecase/auth/sign_up_usecase.dart';
import 'sign_up_state.dart';

class SignUpViewModel extends ChangeNotifier {
  final SignUpUseCase _signUpUseCase;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  SignUpState _state = SignUpState.initial();
  SignUpState get state => _state;

  SignUpViewModel({required SignUpUseCase signUpUseCase})
      : _signUpUseCase = signUpUseCase {
    emailController.addListener(_onEmailChanged);
    passwordController.addListener(_onPasswordChanged);
    confirmPasswordController.addListener(_onConfirmPasswordChanged);
    displayNameController.addListener(_onDisplayNameChanged);
  }

  void _updateState(SignUpState newState) {
    _state = newState;
    notifyListeners();
  }

  void _onEmailChanged() {
    _updateState(_state.copyWith(
      email: emailController.text,
      errorMessage: null,
    ));
  }

  void _onPasswordChanged() {
    _updateState(_state.copyWith(
      password: passwordController.text,
      errorMessage: null,
    ));
  }

  void _onConfirmPasswordChanged() {
    _updateState(_state.copyWith(
      confirmPassword: confirmPasswordController.text,
      errorMessage: null,
    ));
  }

  void _onDisplayNameChanged() {
    _updateState(_state.copyWith(
      displayName: displayNameController.text,
      errorMessage: null,
    ));
  }

  void toggleObscurePassword() {
    _updateState(_state.copyWith(obscurePassword: !_state.obscurePassword));
  }

  void toggleObscureConfirmPassword() {
    _updateState(_state.copyWith(
      obscureConfirmPassword: !_state.obscureConfirmPassword,
    ));
  }

  Future<void> signUp() async {
    if (!_state.isValid) return;

    _updateState(_state.copyWith(isLoading: true, errorMessage: null));

    final result = await _signUpUseCase(
      email: _state.email.trim(),
      password: _state.password,
      confirmPassword: _state.confirmPassword,
      displayName: _state.displayName.isNotEmpty ? _state.displayName : null,
    );

    result.when(
      success: (user) {
        _updateState(_state.copyWith(
          isLoading: false,
          isSignUpSuccess: true,
          successMessage: '회원가입 성공!',
        ));
      },
      error: (failure) {
        _updateState(_state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ));
      },
    );
  }

  void clearError() {
    _updateState(_state.copyWith(errorMessage: null));
  }

  @override
  void dispose() {
    emailController.removeListener(_onEmailChanged);
    passwordController.removeListener(_onPasswordChanged);
    confirmPasswordController.removeListener(_onConfirmPasswordChanged);
    displayNameController.removeListener(_onDisplayNameChanged);
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    displayNameController.dispose();
    super.dispose();
  }
}

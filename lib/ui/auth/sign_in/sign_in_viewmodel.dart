import 'package:flutter/material.dart';

import '../../../domain/usecase/auth/apple_sign_in_usecase.dart';
import '../../../domain/usecase/auth/google_sign_in_usecase.dart';
import '../../../domain/usecase/auth/sign_in_usecase.dart';
import 'sign_in_state.dart';

class SignInViewModel extends ChangeNotifier {
  final SignInUseCase _signInUseCase;
  final GoogleSignInUseCase _googleSignInUseCase;
  final AppleSignInUseCase _appleSignInUseCase;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  SignInState _state = SignInState.initial();
  SignInState get state => _state;

  SignInViewModel({
    required SignInUseCase signInUseCase,
    required GoogleSignInUseCase googleSignInUseCase,
    required AppleSignInUseCase appleSignInUseCase,
  })  : _signInUseCase = signInUseCase,
        _googleSignInUseCase = googleSignInUseCase,
        _appleSignInUseCase = appleSignInUseCase {
    emailController.addListener(_onEmailChanged);
    passwordController.addListener(_onPasswordChanged);
  }

  void _updateState(SignInState newState) {
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

  void toggleObscurePassword() {
    _updateState(_state.copyWith(obscurePassword: !_state.obscurePassword));
  }

  Future<void> signIn() async {
    if (!_state.isValid) return;

    _updateState(_state.copyWith(isLoading: true, errorMessage: null));

    final result = await _signInUseCase(
      email: _state.email.trim(),
      password: _state.password,
    );

    result.when(
      success: (user) {
        _updateState(_state.copyWith(
          isLoading: false,
          isLoginSuccess: true,
          successMessage: '로그인 성공!',
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

  Future<void> signInWithGoogle() async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));

    final result = await _googleSignInUseCase();

    result.when(
      success: (user) {
        _updateState(_state.copyWith(
          isLoading: false,
          isLoginSuccess: true,
          successMessage: 'Google 로그인 성공!',
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

  Future<void> signInWithApple() async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));

    final result = await _appleSignInUseCase();

    result.when(
      success: (user) {
        _updateState(_state.copyWith(
          isLoading: false,
          isLoginSuccess: true,
          successMessage: 'Apple 로그인 성공!',
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

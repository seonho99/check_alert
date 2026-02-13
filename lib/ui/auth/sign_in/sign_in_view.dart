import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/route/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import 'sign_in_state.dart';
import 'sign_in_viewmodel.dart';

class SignInView extends StatelessWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<SignInViewModel>(
          builder: (context, viewModel, child) {
            // 로그인 성공 시 홈으로 이동
            if (viewModel.state.isLoginSuccess) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go(AppRoutes.home);
              });
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: viewModel.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 80),

                    // 앱 타이틀
                    Text(
                      '체크 알리미',
                      style: AppTextStyles.heading2Bold.copyWith(
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '매일 체크하는 습관 관리',
                      style: AppTextStyles.body1Regular.copyWith(
                        color: AppColors.subtleText,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // 이메일 입력
                    TextFormField(
                      controller: viewModel.emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.validateEmail,
                      decoration: const InputDecoration(
                        labelText: '이메일',
                        hintText: 'example@email.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 비밀번호 입력
                    TextFormField(
                      controller: viewModel.passwordController,
                      obscureText: viewModel.state.obscurePassword,
                      textInputAction: TextInputAction.done,
                      validator: Validators.validatePassword,
                      onFieldSubmitted: (_) => viewModel.signIn(),
                      decoration: InputDecoration(
                        labelText: '비밀번호',
                        hintText: '6자 이상',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            viewModel.state.obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: viewModel.toggleObscurePassword,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 에러 메시지
                    if (viewModel.state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          viewModel.state.errorMessage!,
                          style: AppTextStyles.error(),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // 로그인 버튼
                    ElevatedButton(
                      onPressed: viewModel.state.isValid && !viewModel.state.isLoading
                          ? viewModel.signIn
                          : null,
                      child: viewModel.state.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('로그인'),
                    ),

                    const SizedBox(height: 24),

                    // 구분선
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '또는',
                            style: AppTextStyles.body1Regular.copyWith(
                              color: AppColors.subtleText,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 소셜 로그인 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google 로그인 버튼
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: viewModel.state.isLoading
                                ? null
                                : viewModel.signInWithGoogle,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            child: Image.asset(
                              'assets/logo/google_logo.png',
                              width: 28,
                              height: 28,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        // Apple 로그인 버튼 (iOS만)
                        if (Platform.isIOS) ...[
                          const SizedBox(width: 24),
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              color: Colors.black,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: viewModel.state.isLoading
                                  ? null
                                  : viewModel.signInWithApple,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                              ),
                              child: const Icon(
                                Icons.apple,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 회원가입 링크
                    TextButton(
                      onPressed: () => context.push(AppRoutes.signUp),
                      child: const Text('계정이 없으신가요? 회원가입'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

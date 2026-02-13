import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/route/router.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import 'sign_up_state.dart';
import 'sign_up_viewmodel.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('회원가입'),
      ),
      body: SafeArea(
        child: Consumer<SignUpViewModel>(
          builder: (context, viewModel, child) {
            // 회원가입 성공 시 홈으로 이동
            if (viewModel.state.isSignUpSuccess) {
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
                    const SizedBox(height: 24),

                    // 닉네임 입력 (선택)
                    TextFormField(
                      controller: viewModel.displayNameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: '닉네임 (선택)',
                        hintText: '표시될 이름',
                        prefixIcon: Icon(Icons.person_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),

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
                      textInputAction: TextInputAction.next,
                      validator: Validators.validatePassword,
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
                    const SizedBox(height: 16),

                    // 비밀번호 확인 입력
                    TextFormField(
                      controller: viewModel.confirmPasswordController,
                      obscureText: viewModel.state.obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      validator: (value) => Validators.validateConfirmPassword(
                        value,
                        viewModel.passwordController.text,
                      ),
                      onFieldSubmitted: (_) => viewModel.signUp(),
                      decoration: InputDecoration(
                        labelText: '비밀번호 확인',
                        hintText: '비밀번호를 다시 입력',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            viewModel.state.obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: viewModel.toggleObscureConfirmPassword,
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

                    // 회원가입 버튼
                    ElevatedButton(
                      onPressed: viewModel.state.isValid && !viewModel.state.isLoading
                          ? viewModel.signUp
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
                          : const Text('회원가입'),
                    ),

                    const SizedBox(height: 16),

                    // 로그인 링크
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('이미 계정이 있으신가요? 로그인'),
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

import 'package:andone/sign_up_page/sign_up_page_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpPageView extends ConsumerWidget {
  SignUpPageView({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nicknameController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(signUpPageViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 닉네임 입력
            TextField(
              controller: nicknameController,
              decoration: const InputDecoration(
                labelText: '닉네임',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // 이메일 입력
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // 비밀번호 입력
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호 (6자 이상)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // 회원가입 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final nickname = nicknameController.text.trim();
                        final email = emailController.text.trim();
                        final password = passwordController.text.trim();

                        if (nickname.isEmpty || email.isEmpty || password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('모든 값을 입력해주세요')),
                          );
                          return;
                        }

                        final error = await ref
                            .read(signUpPageViewModelProvider.notifier)
                            .signUp(email, password, nickname);

                        if (error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('회원가입 성공! 로그인해주세요')),
                          );
                          Navigator.pop(context);
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('회원가입'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

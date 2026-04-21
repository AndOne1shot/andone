import 'package:andone/common/pixel_field.dart';
import 'package:andone/sign_up_page/sign_up_page_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const kScreen = Color(0xFFA8C878);

class SignUpPageView extends ConsumerStatefulWidget {
  const SignUpPageView({super.key});

  @override
  ConsumerState<SignUpPageView> createState() => _SignUpPageViewState();
}

class _SignUpPageViewState extends ConsumerState<SignUpPageView>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  final _nicknameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _passConfirmCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _nicknameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _passConfirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(signUpPageViewModelProvider);

    return Scaffold(
      backgroundColor: kScreen,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            children: [
              // 뒤로가기
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: kDark),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // 타이틀
              const Text(
                '* NEW TAMA *',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kDark,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 16),

              // 문어 캐릭터 바운스 애니메이션
              AnimatedBuilder(
                animation: _bounceAnim,
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, _bounceAnim.value),
                  child: Image.asset(
                    'assets/image/character/my_pet_right.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 닉네임
              PixelField(
                label: 'NAME:',
                controller: _nicknameCtrl,
                obscure: false,
                icon: Icons.pets,
              ),
              const SizedBox(height: 14),

              // 이메일
              PixelField(
                label: 'EMAIL:',
                controller: _emailCtrl,
                obscure: false,
                icon: Icons.person,
              ),
              const SizedBox(height: 14),

              // 비밀번호
              PixelField(
                label: 'CODE:',
                controller: _passCtrl,
                obscure: true,
                icon: Icons.lock,
              ),
              const SizedBox(height: 14),

              // 비밀번호 확인
              PixelField(
                label: 'CODE CHECK:',
                controller: _passConfirmCtrl,
                obscure: true,
                icon: Icons.lock_outline,
              ),
              const SizedBox(height: 28),

              // 회원가입 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final nickname = _nicknameCtrl.text.trim();
                          final email = _emailCtrl.text.trim();
                          final password = _passCtrl.text.trim();
                          final passwordConfirm = _passConfirmCtrl.text.trim();

                          if (nickname.isEmpty ||
                              email.isEmpty ||
                              password.isEmpty ||
                              passwordConfirm.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('모든 값을 입력해주세요'),
                              ),
                            );
                            return;
                          }

                          if (password != passwordConfirm) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('비밀번호가 일치하지 않습니다'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final error = await ref
                              .read(signUpPageViewModelProvider.notifier)
                              .signUp(email, password, nickname);

                          if (error != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('가입 완료! 로그인해주세요 🐙'),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kDark,
                    foregroundColor: kScreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kScreen,
                          ),
                        )
                      : const Text(
                          '✦  CREATE!',
                          style: TextStyle(
                            fontSize: 15,
                            letterSpacing: 3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

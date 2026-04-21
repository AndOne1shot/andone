import 'package:andone/common/pixel_field.dart';
import 'package:andone/sign_up_page/sign_up_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login_page_view_model.dart';

const kScreen = Color(0xFFA8C878);

class LoginPageView extends ConsumerStatefulWidget {
  const LoginPageView({super.key});

  @override
  ConsumerState<LoginPageView> createState() => _LoginPageViewState();
}

class _LoginPageViewState extends ConsumerState<LoginPageView>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(
      begin: 0,
      end: -8,
    ).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loginPageViewModelProvider);

    return Scaffold(
      backgroundColor: kScreen,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 타이틀
                const Text(
                  '* ANDONE *',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kDark,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 24),

                // 문어 캐릭터 바운스 애니메이션
                AnimatedBuilder(
                  animation: _bounceAnim,
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, _bounceAnim.value),
                    child: Image.asset(
                      'assets/image/character/my_pet_right.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 이메일 입력
                PixelField(
                  label: 'EMAIL:',
                  controller: _emailCtrl,
                  obscure: false,
                  icon: Icons.person,
                ),
                const SizedBox(height: 14),

                // 비밀번호 입력
                PixelField(
                  label: 'CODE:',
                  controller: _passCtrl,
                  obscure: true,
                  icon: Icons.lock,
                ),
                const SizedBox(height: 24),

                // 로그인 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final email = _emailCtrl.text.trim();
                            final password = _passCtrl.text.trim();

                            if (email.isEmpty || password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('모든 값을 입력해주세요')),
                              );
                              return;
                            }

                            final error = await ref
                                .read(loginPageViewModelProvider.notifier)
                                .signIn(email, password);

                            if (error != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error),
                                  backgroundColor: Colors.red,
                                ),
                              );
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
                            'START!',
                            style: TextStyle(
                              fontSize: 15,
                              letterSpacing: 3,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // OR 구분선
                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: kScreenBorder, thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'OR',
                        style: TextStyle(fontSize: 11, color: kMid),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: kScreenBorder, thickness: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 회원가입 버튼
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SignUpPageView(),
                              ),
                            );
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kDark,
                      backgroundColor: kLight,
                      side: const BorderSide(color: kDark, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      '✦  NEW ACCOUNT',
                      style: TextStyle(
                        fontSize: 15,
                        letterSpacing: 3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 비밀번호 찾기
                // Text(
                //   '※ CODE 잊어버렸어요',
                //   style: TextStyle(fontSize: 11, color: kMid),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

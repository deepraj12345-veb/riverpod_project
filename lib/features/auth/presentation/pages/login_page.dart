import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veggie_mart/core/theme/app_theme.dart';
import 'package:veggie_mart/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:veggie_mart/core/widgets/custom_text.dart';
import 'package:veggie_mart/core/widgets/custom_network_image.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    context.push('/otp', extra: _phoneCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.55,
            child: Image.asset(
              'assets/images/login_bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.55,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.2),
                    Colors.white.withOpacity(0.8),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.4, 0.8, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),

                          // ── Logo ──────────────────────────────────────────────
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppTheme.primaryGreen,
                                  AppTheme.lightGreen,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: const CustomNetworkImage(
                                imageUrl:
                                    'https://images.unsplash.com/photo-1542838132-92c53300491e?w=200',
                                fit: BoxFit.cover,
                                placeholder: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                errorWidget: Icon(
                                  Icons.restaurant_menu,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── App Name ──────────────────────────────────────────
                          const CustomText(
                            'VeggieMart',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                              letterSpacing: 1.2,
                            ),
                          ),

                          const SizedBox(height: 80),

                          SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CustomText(
                                    'Welcome Back 👋',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textDark,
                                      letterSpacing: -0.5,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Mobile Number
                                  AuthTextField(
                                    controller: _phoneCtrl,
                                    hint: 'Enter your 10-digit number',
                                    icon: Icons.phone_android_outlined,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 10,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Please enter mobile number';
                                      }
                                      if (v.length < 10) {
                                        return 'Invalid mobile number';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  GradientButton(
                                    text: 'Get OTP',
                                    isLoading: false,
                                    onPressed: _login,
                                  ),
                                ],
                              )),
                          const SizedBox(height: 20),

                          // Social divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: AppTheme.primaryGreen.withOpacity(0.3),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: CustomText(
                                  'Or continue with',
                                  style: TextStyle(
                                    color: AppTheme.textGrey,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: AppTheme.primaryGreen.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          SocialButton(
                            icon: Image.asset(
                              'assets/images/google.png',
                              width: 22,
                              height: 22,
                            ),
                            label: 'Google',
                            onTap: () {},
                          ),
                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CustomText(
                                "Don't have an account? ",
                                style: TextStyle(color: AppTheme.textGrey),
                              ),
                              GestureDetector(
                                onTap: () => context.go('/signup'),
                                child: const CustomText(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: AppTheme.primaryGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

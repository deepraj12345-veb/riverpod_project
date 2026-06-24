import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_project/core/theme/app_theme.dart';
import 'package:riverpod_project/core/widgets/suggestion_field.dart';
import 'package:riverpod_project/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:riverpod_project/core/widgets/custom_text.dart';

const _nameSuggestions = [
  'Alex Johnson',
  'Emma Williams',
  'James Brown',
  'Olivia Davis',
  'Liam Martinez',
  'Sophia Wilson',
  'Noah Taylor',
  'Isabella Anderson',
  'Lucas Thomas',
  'Mia Jackson',
  'Aiden White',
  'Charlotte Harris',
];
const _emailSuggestions = [
  'alex.johnson@gmail.com',
  'emma.w@gmail.com',
  'user@gmail.com',
  'user@yahoo.com',
  'user@hotmail.com',
  'user@outlook.com',
  'user@icloud.com',
  'shopper@gmail.com',
  'newuser@gmail.com',
];
const _phoneSuggestions = [
  '+1 234 567 8900',
  '+1 555 000 1234',
  '+44 20 7946 0958',
  '+91 98765 43210',
  '+61 400 000 000',
  '+1 800 555 0199',
  '+1 (555) 234-5678',
  '+1 (555) 987-6543',
];

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: CustomText('Please agree to terms and conditions')),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isLoading = false);
    context.go('/otp', extra: _phoneCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppTheme.bgWhite,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Header
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppTheme.primaryGreen
                                    .withOpacity(0.2)),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppTheme.primaryGreen,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CustomText(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Progress indicators
                  Row(
                    children: [
                      _StepDot(active: true, label: '1\nDetails'),
                      Expanded(
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryGreen,
                                AppTheme.primaryGreen.withOpacity(0.2),
                              ],
                            ),
                          ),
                        ),
                      ),
                      _StepDot(active: false, label: '2\nVerify'),
                      Expanded(
                        child: Container(
                            height: 2,
                            color:
                                AppTheme.primaryGreen.withOpacity(0.2)),
                      ),
                      _StepDot(active: false, label: '3\nDone'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppTheme.primaryGreen.withOpacity(0.15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SuggestionField(
                            controller: _nameCtrl,
                            label: 'Full Name',
                            hint: 'John Doe',
                            icon: Icons.person_outline_rounded,
                            suggestions: _nameSuggestions,
                            validator: (v) =>
                                (v?.isEmpty ?? true) ? 'Enter your name' : null,
                          ),
                          const SizedBox(height: 16),
                          SuggestionField(
                            controller: _emailCtrl,
                            label: 'Email Address',
                            hint: 'you@example.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            suggestions: _emailSuggestions,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Enter email';
                              if (!v.contains('@')) return 'Invalid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          SuggestionField(
                            controller: _phoneCtrl,
                            label: 'Phone Number',
                            hint: '+1 234 567 8900',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            suggestions: _phoneSuggestions,
                            validator: (v) => (v?.length ?? 0) < 10
                                ? 'Enter valid phone'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          AuthTextField(
                            controller: _passCtrl,
                            label: 'Password',
                            hint: '••••••••',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePass,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePass
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppTheme.primaryGreen,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePass = !_obscurePass),
                            ),
                            validator: (v) => (v?.length ?? 0) < 6
                                ? 'Min 6 characters'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          // Terms checkbox
                          GestureDetector(
                            onTap: () =>
                                setState(() => _agreeToTerms = !_agreeToTerms),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: _agreeToTerms
                                        ? AppTheme.primaryGreen
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: _agreeToTerms
                                          ? AppTheme.primaryGreen
                                          : AppTheme.primaryGreen
                                              .withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: _agreeToTerms
                                      ? const Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: RichText(
                                    text: const TextSpan(
                                      text: 'I agree to the ',
                                      style: TextStyle(
                                        color: AppTheme.textGrey,
                                        fontSize: 13,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Terms of Service',
                                          style: TextStyle(
                                            color: AppTheme.primaryGreen,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        TextSpan(text: ' and '),
                                        TextSpan(
                                          text: 'Privacy Policy',
                                          style: TextStyle(
                                            color: AppTheme.primaryGreen,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          GradientButton(
                            text: 'Create Account',
                            isLoading: _isLoading,
                            onPressed: _signup,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CustomText(
                        'Already have an account? ',
                        style: TextStyle(color: AppTheme.textGrey),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: const CustomText(
                          'Login',
                          style: TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w600,
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
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool active;
  final String label;

  const _StepDot({required this.active, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? AppTheme.primaryGreen
                : AppTheme.primaryGreen.withOpacity(0.2),
          ),
          child: Center(
            child: Icon(
              active ? Icons.edit_rounded : Icons.circle,
              color: Colors.white,
              size: active ? 16 : 8,
            ),
          ),
        ),
        const SizedBox(height: 4),
        CustomText(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: active ? AppTheme.primaryGreen : AppTheme.textGrey,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

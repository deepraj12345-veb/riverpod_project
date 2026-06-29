import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:veggie_mart/core/theme/app_theme.dart';
import 'package:veggie_mart/presentation/providers/auth_provider.dart';
import 'package:veggie_mart/core/widgets/auth_widgets.dart';
import 'package:veggie_mart/core/widgets/custom_text.dart';

class OtpPage extends ConsumerStatefulWidget {
  final String phone;
  const OtpPage({super.key, required this.phone});

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage>
    with TickerProviderStateMixin {
  final _otpController = TextEditingController();
  bool _isVerifying = false;
  bool _hasError = false;
  int _resendSeconds = 59;
  late AnimationController _shakeCtrl;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _shakeAnim = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
    _fadeCtrl.forward();
    // Start resend timer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startResendTimer();
    });
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
        return true;
      }
      return false;
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _fadeCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length < 4) return;
    setState(() {
      _isVerifying = true;
      _hasError = false;
    });
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    final isValid = await ref
        .read(authProvider.notifier)
        .verifyOtp(widget.phone, _otpController.text, 'New User');
    if (!mounted) return;
    if (isValid) {
      // Login is called inside controller.verifyOtp, so redirect is triggered automatically
    } else {
      setState(() {
        _hasError = true;
        _isVerifying = false;
      });
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppTheme.textDark,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor, width: 1.5),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppTheme.primaryColor, width: 2),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppTheme.secondaryColor, width: 2),
      ),
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/signup'),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppTheme.textDark,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // OTP illustration
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                      ),
                      shape: BoxShape.circle,
                      // Removed shadow for clean design
                    ),
                    child: const Icon(
                      Icons.sms_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const CustomText(
                    'Verify Your Phone 📱',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    'We sent a 6-digit code to\n${widget.phone.isEmpty ? '+1 *** *** 5678' : widget.phone}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textGrey,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Hint box
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const CustomText(
                      '💡 Demo OTP: 1234',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // OTP Input
                  AnimatedBuilder(
                    animation: _shakeAnim,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          _hasError
                              ? (_shakeCtrl.value * 10 - 5) *
                                    (1 - _shakeCtrl.value)
                              : 0,
                          0,
                        ),
                        child: child,
                      );
                    },
                    child: Pinput(
                      length: 4,
                      controller: _otpController,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: focusedPinTheme,
                      errorPinTheme: errorPinTheme,
                      forceErrorState: _hasError,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_hasError)
                    const CustomText(
                      '❌ Invalid OTP. Please try again.',
                      style: TextStyle(
                        color: AppTheme.secondaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 20),
                  GradientButton(
                    text: _isVerifying ? 'Verifying...' : 'Verify & Continue',
                    isLoading: _isVerifying,
                    onPressed: _verifyOtp,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Flexible(
                        child: CustomText(
                          "Didn't receive the code? ",
                          style: TextStyle(color: AppTheme.textGrey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _resendSeconds > 0
                          ? CustomText(
                              'Resend in 0:${_resendSeconds.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                ref
                                    .read(authProvider.notifier)
                                    .sendOtp(widget.phone);
                                setState(() => _resendSeconds = 59);
                                _startResendTimer();
                              },
                              child: const CustomText(
                                'Resend OTP',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
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

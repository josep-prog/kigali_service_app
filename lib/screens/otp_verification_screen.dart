import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers.dart';
import '../ui_helpers.dart';
import 'home_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get otpCode => _controllers.map((c) => c.text).join();

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyOtp() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    
    if (user == null || otpCode.length != 6) return;
    
    final success = await authProvider.verifyOtp(user.email!, otpCode);
    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      64,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  const SizedBox(height: 32),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [kGreen, kGreenLight]),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.security_rounded, size: 50, color: Colors.white),
                  ).animate().scale(begin: const Offset(0.6, 0.6), duration: 600.ms),
                  const SizedBox(height: 32),
                  Text(
                    'Enter Verification Code',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: kCream,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We sent a 6-digit code to\n${authProvider.currentUser?.email}',
                    style: GoogleFonts.dmSans(fontSize: 13, color: kMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      final hasValue = _controllers[index].text.isNotEmpty;
                      return Container(
                        width: 45,
                        height: 55,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: kSurface2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: hasValue ? kGreenLight : Colors.white12,
                            width: hasValue ? 1.5 : 1.0,
                          ),
                        ),
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: GoogleFonts.dmSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: kGreenLight,
                          ),
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (value) {
                            _onChanged(value, index);
                            setState(() {});
                          },
                        ),
                      ).animate(delay: (index * 70).ms).fadeIn(duration: 300.ms);
                    }),
                  ),
                  const SizedBox(height: 40),
                  if (authProvider.error != null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              authProvider.error!,
                              style: GoogleFonts.dmSans(fontSize: 13, color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  kGradientButton(
                    'Verify Code',
                    _verifyOtp,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () => authProvider.resendVerificationEmail(),
                    child: Text(
                      'Resend Code',
                      style: GoogleFonts.dmSans(
                        color: kGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => authProvider.signOut(),
                    child: Text(
                      'Logout',
                      style: GoogleFonts.dmSans(color: kMuted),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers.dart';
import '../ui_helpers.dart';
import 'home_screen.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

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

                    // Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [kGreen, kGreenLight]),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mark_email_read_rounded,
                          size: 50, color: Colors.white),
                    ).animate().scale(
                        begin: const Offset(0.6, 0.6), duration: 600.ms),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Verify Your Email',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: kCream,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'We sent a verification link to',
                      style: GoogleFonts.dmSans(fontSize: 13, color: kMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      authProvider.currentUser?.email ?? '',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: kGreenLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kSurface2,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: kGreenLight, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Open your email app, click the verification link, then tap the button below.',
                              style: GoogleFonts.dmSans(
                                  fontSize: 12, color: kMuted, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Error / info message
                    if (authProvider.error != null)
                      Container(
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: authProvider.error!.contains('sent')
                              ? kGreen.withValues(alpha: 0.15)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: authProvider.error!.contains('sent')
                                ? kGreen.withValues(alpha: 0.4)
                                : Colors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              authProvider.error!.contains('sent')
                                  ? Icons.check_circle_outline
                                  : Icons.error_outline,
                              color: authProvider.error!.contains('sent')
                                  ? kGreenLight
                                  : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                authProvider.error!,
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: authProvider.error!.contains('sent')
                                      ? kGreenLight
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Check verification button
                    kGradientButton(
                      authProvider.isLoading
                          ? 'Checking...'
                          : "I've Verified My Email",
                      authProvider.isLoading
                          ? null
                          : () async {
                              final success =
                                  await authProvider.checkEmailVerified();
                              if (success && context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const HomeScreen()),
                                  (_) => false,
                                );
                              }
                            },
                      icon: Icons.check_circle,
                    ),

                    const SizedBox(height: 16),

                    // Resend email
                    TextButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () => authProvider.resendVerificationEmail(),
                      child: Text(
                        'Resend Verification Email',
                        style: GoogleFonts.dmSans(
                          color: kGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Logout
                    TextButton(
                      onPressed: () => authProvider.signOut(),
                      child: Text(
                        'Use Different Account',
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

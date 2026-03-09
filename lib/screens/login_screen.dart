import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers.dart';
import '../ui_helpers.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const KAmbientBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 52, 24, 32),
              child: Column(
                children: [
                  // ── Hero ────────────────────────────────────────────
                  Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [kGreen, kGreenLight],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: kGreen.withValues(alpha: 0.55),
                              blurRadius: 22,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.location_city_rounded,
                            size: 40, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'KIGALI ',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: kCream,
                                letterSpacing: 2.5,
                              ),
                            ),
                            TextSpan(
                              text: 'GUIDE',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 30,
                                fontWeight: FontWeight.w300,
                                color: kGreenLight,
                                letterSpacing: 2.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'City Services & Places',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: kMuted,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1),

                  const SizedBox(height: 40),

                  // ── Glass card ──────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                    decoration: BoxDecoration(
                      color: kSurface.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 36,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: kCream,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sign in to your account to continue',
                            style:
                                GoogleFonts.dmSans(fontSize: 13, color: kMuted),
                          ),
                          const SizedBox(height: 28),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              hintText: 'you@example.com',
                              prefixIcon:
                                  Icon(Icons.alternate_email_rounded),
                            ),
                            validator: (v) =>
                                v!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.key_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                  color: kMuted,
                                  size: 20,
                                ),
                                onPressed: () => setState(() =>
                                    _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) =>
                                v!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 24),

                          // Error banner
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              if (auth.error != null) {
                                return Container(
                                  margin:
                                      const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color:
                                        kTerra.withValues(alpha: 0.10),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    border: Border.all(
                                        color: kTerra.withValues(
                                            alpha: 0.35)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                          Icons.warning_amber_rounded,
                                          color: kTerra,
                                          size: 18),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          auth.error!,
                                          style: GoogleFonts.dmSans(
                                              color: kTerra,
                                              fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),

                          // Sign in button
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              return kGradientButton(
                                auth.isLoading
                                    ? 'Signing in…'
                                    : 'Sign In',
                                auth.isLoading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!
                                            .validate()) {
                                          await auth.signIn(
                                              _emailController.text,
                                              _passwordController.text);
                                        }
                                      },
                                icon: Icons.arrow_forward_rounded,
                              );
                            },
                          ),
                          const SizedBox(height: 22),

                          // Sign up link
                          Center(
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text(
                                  'New to Kigali Guide?  ',
                                  style: GoogleFonts.dmSans(
                                      color: kMuted, fontSize: 13),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const SignupScreen()),
                                  ),
                                  child: Text(
                                    'Create account',
                                    style: GoogleFonts.dmSans(
                                      color: kGreenLight,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

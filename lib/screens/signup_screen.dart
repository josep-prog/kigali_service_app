import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers.dart';
import '../ui_helpers.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  int _strengthLevel = 0;
  Color _strengthColor = Colors.white12;
  String _strengthLabel = '';
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
  }

  void _checkPasswordStrength() {
    final p = _passwordController.text;
    if (p.isEmpty) {
      setState(() {
        _strengthLevel = 0;
        _strengthColor = Colors.white12;
        _strengthLabel = '';
      });
      return;
    }
    int s = 0;
    if (p.length >= 8) s++;
    if (p.contains(RegExp(r'[A-Z]'))) s++;
    if (p.contains(RegExp(r'[0-9]'))) s++;
    if (p.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) s++;
    const colors = [Colors.red, Colors.red, Colors.orange, kGold, kGreenLight];
    const labels = ['', 'Weak', 'Fair', 'Strong', 'Very Strong'];
    setState(() {
      _strengthLevel = s;
      _strengthColor = colors[s];
      _strengthLabel = labels[s];
    });
  }

  @override
  void dispose() {
    _passwordController.removeListener(_checkPasswordStrength);
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
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
                            'Create account',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: kCream,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Join and explore Kigali\'s best places',
                            style:
                                GoogleFonts.dmSans(fontSize: 13, color: kMuted),
                          ),
                          const SizedBox(height: 28),

                          // Full name
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              hintText: 'Your name',
                              prefixIcon: Icon(Icons.badge_rounded),
                            ),
                            validator: (v) =>
                                v!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),

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
                                v!.length < 6 ? 'Min 6 characters' : null,
                          ),

                          // Strength meter
                          if (_strengthLevel > 0) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: List.generate(
                                4,
                                (i) => Expanded(
                                  child: Container(
                                    height: 3,
                                    margin: EdgeInsets.only(
                                        right: i < 3 ? 5 : 0),
                                    decoration: BoxDecoration(
                                      color: i < _strengthLevel
                                          ? _strengthColor
                                          : Colors.white12,
                                      borderRadius:
                                          BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _strengthLabel,
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _strengthColor,
                                ),
                              ),
                            ),
                          ],
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

                          // Create account button
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              return kGradientButton(
                                auth.isLoading
                                    ? 'Creating account…'
                                    : 'Create Account',
                                auth.isLoading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!
                                            .validate()) {
                                          await auth.signUp(
                                              _emailController.text,
                                              _passwordController.text,
                                              _nameController.text);
                                          if (auth.error == null &&
                                              context.mounted) {
                                            Navigator.pop(context);
                                          }
                                        }
                                      },
                                icon: Icons.arrow_forward_rounded,
                              );
                            },
                          ),
                          const SizedBox(height: 22),

                          // Login link
                          Center(
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account?  ',
                                  style: GoogleFonts.dmSans(
                                      color: kMuted, fontSize: 13),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text(
                                    'Sign in',
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

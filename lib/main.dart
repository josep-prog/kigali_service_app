import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'providers.dart';
import 'ui_helpers.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/email_verification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ListingsProvider()),
      ],
      child: MaterialApp(
        title: 'Kigali City Services',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: kBg,
          primaryColor: kGreen,
          colorScheme: const ColorScheme.dark(
            primary: kGreen,
            secondary: kTerra,
            surface: kSurface,
          ),
          textTheme: TextTheme(
            displayMedium: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: kCream,
            ),
            titleLarge: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: kCream,
            ),
            titleMedium: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: kCream,
            ),
            bodyMedium: GoogleFonts.dmSans(
              fontSize: 13,
              color: kMuted,
            ),
            labelSmall: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: kMuted,
              letterSpacing: 0.8,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: kSurface2,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kGreenLight, width: 1.5),
            ),
            prefixIconColor: kGreenLight,
            hintStyle: GoogleFonts.dmSans(color: kMuted, fontSize: 14),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: kSurface,
            selectedItemColor: kGreenLight,
            unselectedItemColor: kMuted,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: kSurface,
            indicatorColor: kGreen.withValues(alpha: 0.18),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: kGreenLight, size: 24);
              }
              return const IconThemeData(color: kMuted, size: 24);
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: kGreenLight);
              }
              return GoogleFonts.dmSans(fontSize: 11, color: kMuted);
            }),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: kSurface,
            elevation: 0,
            titleTextStyle: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: kCream,
            ),
            iconTheme: const IconThemeData(color: kCream),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: kGreen,
            foregroundColor: Colors.white,
          ),
          chipTheme: ChipThemeData(
            backgroundColor: kSurface2,
            selectedColor: kGreen,
            labelStyle: GoogleFonts.dmSans(fontSize: 12, color: kCream),
            side: const BorderSide(color: Colors.white12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          cardTheme: const CardThemeData(
            color: kSurface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              side: BorderSide(color: Colors.white12),
            ),
            margin: EdgeInsets.only(bottom: 12),
          ),
          dividerTheme:
              const DividerThemeData(color: Colors.white12, space: 1),
          switchTheme: SwitchThemeData(
            thumbColor: WidgetStateProperty.resolveWith(
              (s) =>
                  s.contains(WidgetState.selected) ? kGreenLight : kMuted,
            ),
            trackColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected)
                  ? kGreen.withValues(alpha: 0.5)
                  : kSurface2,
            ),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Future<bool>? _verificationFuture;
  String? _lastCheckedUid;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return StreamBuilder(
      stream: authProvider.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          final user = snapshot.data;
          if (user != null) {
            if (_lastCheckedUid != user.uid) {
              _lastCheckedUid = user.uid;
              _verificationFuture = authProvider.isUserVerified();
            }
            return FutureBuilder<bool>(
              future: _verificationFuture,
              builder: (context, verificationSnapshot) {
                if (verificationSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Scaffold(
                      body: Center(child: CircularProgressIndicator()));
                }

                if (verificationSnapshot.data == true) {
                  return const HomeScreen();
                } else {
                  return const EmailVerificationScreen();
                }
              },
            );
          }
        }

        _lastCheckedUid = null;
        _verificationFuture = null;
        return const LoginScreen();
      },
    );
  }
}

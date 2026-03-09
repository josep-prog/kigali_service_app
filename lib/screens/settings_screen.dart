import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers.dart';
import '../ui_helpers.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: context.read<AuthProvider>().getUserProfile(),
            builder: (context, profileSnapshot) {
              final displayName =
                  profileSnapshot.data?['displayName'] as String? ?? '';
              final initial = displayName.isNotEmpty
                  ? displayName[0].toUpperCase()
                  : (user?.email?[0].toUpperCase() ?? 'U');
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: kGreen,
                      child: Text(
                        initial,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (displayName.isNotEmpty) ...[
                      Text(
                        displayName,
                        style: GoogleFonts.dmSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: kCream,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      user?.email ?? '',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: kMuted,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Card(
            child: SwitchListTile(
              title: Text('Enable Notifications', style: GoogleFonts.dmSans(color: kCream)),
              subtitle: Text('Receive updates about new listings', style: GoogleFonts.dmSans(fontSize: 12, color: kMuted)),
              value: _notificationsEnabled,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: kSurface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.logout, color: kTerra, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Logout',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: kCream,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Are you sure you want to logout?',
                        style: GoogleFonts.dmSans(fontSize: 13, color: kMuted),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white12),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text('Cancel', style: GoogleFonts.dmSans(color: kCream)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                await context.read<AuthProvider>().signOut();
                                if (context.mounted) {
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kTerra,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text('Logout', style: GoogleFonts.dmSans(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            icon: const Icon(Icons.logout, color: kTerra),
            label: Text('Logout', style: GoogleFonts.dmSans(color: kTerra, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

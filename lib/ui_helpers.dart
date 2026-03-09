import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

// ─── Animated Ambient Background (auth screens) ──────────────────────────────

class KAmbientBackground extends StatefulWidget {
  const KAmbientBackground({super.key});

  @override
  State<KAmbientBackground> createState() => _KAmbientBackgroundState();
}

class _KAmbientBackgroundState extends State<KAmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => CustomPaint(
        painter: _GlowPainter(_controller.value),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  final double t;
  const _GlowPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Base background
    canvas.drawRect(rect, Paint()..color = const Color(0xFF0A1929));

    // Blue glow — top-left, breathes slowly
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.65),
          radius: 1.4 + t * 0.25,
          colors: [
            const Color(0xFF1565C0).withValues(alpha: 0.3 + t * 0.1),
            Colors.transparent,
          ],
        ).createShader(rect),
    );

    // Warm accent glow — bottom-right, inverse pulse
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.8, 0.75),
          radius: 0.9 + (1 - t) * 0.2,
          colors: [
            const Color(0xFF0D47A1).withValues(alpha: 0.15 + (1 - t) * 0.08),
            Colors.transparent,
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.t != t;
}

// ─── Theme Colors ─────────────────────────────────────────────────────────────

const kBg = Color(0xFF0A1929);
const kSurface = Color(0xFF0D2137);
const kSurface2 = Color(0xFF132F4C);
const kGreen = Color(0xFF1565C0);
const kGreenLight = Color(0xFF42A5F5);
const kTerra = Color(0xFFFF6B35);
const kGold = Color(0xFFD4A853);
const kCream = Color(0xFFE8E0D4);
const kMuted = Color(0xFF8B8680);

// ─── Category Helpers ─────────────────────────────────────────────────────────

Color kCategoryColor(String category) {
  const colors = {
    'Hospital': Color(0xFFE05A28),
    'Police Station': Color(0xFF3A86FF),
    'Library': Color(0xFFD4A853),
    'Restaurant': Color(0xFFFF6B6B),
    'Café': Color(0xFFA0522D),
    'Park': Color(0xFF52B788),
    'Tourist Attraction': Color(0xFFBB86FC),
  };
  return colors[category] ?? const Color(0xFF8B8680);
}

IconData kCategoryIcon(String category) {
  const icons = {
    'Hospital': Icons.monitor_heart_rounded,
    'Police Station': Icons.shield_rounded,
    'Library': Icons.auto_stories_rounded,
    'Restaurant': Icons.set_meal_rounded,
    'Café': Icons.emoji_food_beverage_rounded,
    'Park': Icons.forest_rounded,
    'Tourist Attraction': Icons.museum_rounded,
  };
  return icons[category] ?? Icons.pin_drop_rounded;
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────────

Widget kGradientButton(String label, VoidCallback? onPressed,
    {IconData? icon}) {
  return SizedBox(
    width: double.infinity,
    height: 52,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kGreen, kGreenLight]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: kGreen.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: icon != null
            ? Icon(icon, color: Colors.white, size: 18)
            : const SizedBox.shrink(),
        label: Text(
          label,
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}

Widget kCategoryBadge(String category) {
  final color = kCategoryColor(category);
  final icon = kCategoryIcon(category);
  return Container(
    width: 46,
    height: 46,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Icon(icon, color: color, size: 20),
  );
}

Widget kShimmerCard() => Shimmer.fromColors(
      baseColor: kSurface,
      highlightColor: kSurface2,
      child: Container(
        height: 90,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );

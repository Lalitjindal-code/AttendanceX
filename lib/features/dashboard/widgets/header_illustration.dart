import 'dart:math' as math;
import 'package:flutter/material.dart';

class HeaderIllustration extends StatefulWidget {
  const HeaderIllustration({super.key});

  @override
  State<HeaderIllustration> createState() => _HeaderIllustrationState();
}

class _HeaderIllustrationState extends State<HeaderIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isAmoled = theme.colorScheme.surface.value == 0xFF000000;

    // Connect dynamic Sun/Moon directly to Light/Dark mode state as well as system time
    // If theme brightness is Light, force isDayTime = true to show the Sun (and vice versa)
    final isDayTime = brightness == Brightness.light;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(140, 80),
          painter: _DynamicSkyPainter(
            animationValue: _controller.value,
            isDayTime: isDayTime,
            brightness: brightness,
            isAmoled: isAmoled,
            primaryColor: theme.colorScheme.primary,
            secondaryColor: theme.colorScheme.secondary,
            surfaceColor: theme.colorScheme.surface,
          ),
        );
      },
    );
  }
}

class _DynamicSkyPainter extends CustomPainter {
  final double animationValue;
  final bool isDayTime;
  final Brightness brightness;
  final bool isAmoled;
  final Color primaryColor;
  final Color secondaryColor;
  final Color surfaceColor;

  _DynamicSkyPainter({
    required this.animationValue,
    required this.isDayTime,
    required this.brightness,
    required this.isAmoled,
    required this.primaryColor,
    required this.secondaryColor,
    required this.surfaceColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Background sky details based on time of day
    if (!isDayTime) {
      _drawStars(canvas, size);
      _drawConstellations(canvas, size);
      _drawShootingStar(canvas, size);
    } else {
      _drawDayBirds(canvas, size);
      _drawLightShafts(canvas, size);
    }

    // 2. Draw Sun or Moon with pulsing animation
    final pulseScale = 1.0 + 0.05 * math.sin(animationValue * 2 * math.pi * 3);
    final celestialCenter = Offset(size.width - 30, 24);

    if (isDayTime) {
      // Draw Sun with layered glowing gradients (vibrant orange/amber)
      final sunOuterGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFB300).withValues(alpha: 0.35),
            const Color(0xFFFFB300).withValues(alpha: 0.0),
          ],
        ).createShader(
            Rect.fromCircle(center: celestialCenter, radius: 36 * pulseScale));
      canvas.drawCircle(celestialCenter, 36 * pulseScale, sunOuterGlow);

      final sunPaint = Paint()
        ..color = const Color(0xFFFFB300)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(celestialCenter, 9, sunPaint);

      // Rotating sun rays
      final rayPaint = Paint()
        ..color = const Color(0xFFFFB300).withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;

      final rotAngle = animationValue * 2 * math.pi;
      for (int i = 0; i < 8; i++) {
        final angle = (i * math.pi / 4) + rotAngle * 0.05;
        final start = Offset(
          celestialCenter.dx + 13 * math.cos(angle),
          celestialCenter.dy + 13 * math.sin(angle),
        );
        final end = Offset(
          celestialCenter.dx + 18 * math.cos(angle),
          celestialCenter.dy + 18 * math.sin(angle),
        );
        canvas.drawLine(start, end, rayPaint);
      }
    } else {
      // Draw Moon with detailed layered shadows and cooling violet/silver glow
      final moonOuterGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            primaryColor.withValues(alpha: 0.35),
            primaryColor.withValues(alpha: 0.0),
          ],
        ).createShader(
            Rect.fromCircle(center: celestialCenter, radius: 30 * pulseScale));
      canvas.drawCircle(celestialCenter, 30 * pulseScale, moonOuterGlow);

      // Draw crescent moon shape using Path subtract/clip logic (fully clipped crescent)
      final moonPath = Path()
        ..addOval(Rect.fromCircle(center: celestialCenter, radius: 8.5));

      final clipPath = Path()
        ..addOval(Rect.fromCircle(
            center: celestialCenter + const Offset(-4, -2.5), radius: 8.0));

      final crescentPath =
          Path.combine(PathOperation.difference, moonPath, clipPath);

      final moonPaint = Paint()
        ..color = isAmoled ? const Color(0xFFC5C0FF) : const Color(0xFF8C7CFF)
        ..style = PaintingStyle.fill;

      canvas.drawPath(crescentPath, moonPaint);

      // Moon inner highlight detail: Draw arc on the outer crescent side ONLY
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      // Draw a partial arc along the right edge of the moon sphere to prevent a full closed circle outline loop
      canvas.drawArc(
        Rect.fromCircle(center: celestialCenter, radius: 8.5),
        -math.pi / 3, // Start angle
        math.pi * 0.8, // Sweep angle (only wraps the outer curve)
        false,
        highlightPaint,
      );
    }

    // 3. Draw Floating Clouds
    final cloud1X = (size.width * 0.3) +
        (size.width * 0.4) * math.sin(animationValue * 2 * math.pi);
    _drawCloud(canvas, Offset(cloud1X, 20), 16);

    final cloud2X =
        (size.width * 0.72) + 14 * math.cos(animationValue * 2 * math.pi * 2);
    _drawCloud(canvas, Offset(cloud2X, 14), 11);

    // 4. Draw hills (Path) - Make them solid colored instead of gradient shaders ending in surfaceColor.
    // Linear gradients ending in surfaceColor with offset heights caused them to disappear due to bounding box sizes.
    final backHillPath = Path();
    backHillPath.moveTo(0, size.height);
    backHillPath.quadraticBezierTo(
        size.width * 0.25, size.height - 20, size.width * 0.5, size.height - 5);
    backHillPath.quadraticBezierTo(
        size.width * 0.75, size.height - 30, size.width, size.height - 10);
    backHillPath.lineTo(size.width, size.height);
    backHillPath.close();

    // Solid hill colors for absolute visibility in all brightness settings
    final Color backHillColor = isDayTime
        ? const Color(0xFFE8DBC5) // Solid warm sand beige in light mode
        : (isAmoled ? const Color(0xFF1B1936) : const Color(0xFF282158));

    final backHillPaint = Paint()
      ..color = backHillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(backHillPath, backHillPaint);

    final frontHillPath = Path();
    frontHillPath.moveTo(0, size.height);
    frontHillPath.quadraticBezierTo(
        size.width * 0.2, size.height - 5, size.width * 0.4, size.height - 15);
    frontHillPath.quadraticBezierTo(
        size.width * 0.6, size.height, size.width * 0.8, size.height - 15);
    frontHillPath.lineTo(size.width, size.height);
    frontHillPath.close();

    final Color frontHillColor = isDayTime
        ? const Color(0xFFD4C2A8) // Solid darker sand accent in light mode
        : (isAmoled ? const Color(0xFF2E2463) : const Color(0xFF3B2F7E));

    final frontHillPaint = Paint()
      ..color = frontHillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(frontHillPath, frontHillPaint);

    // 5. Draw trees (Swaying dynamically with a virtual wind)
    final swayOffset = 3.5 * math.sin(animationValue * 2 * math.pi * 2);
    _drawTree(
        canvas, Offset(size.width * 0.15, size.height - 10), 22, swayOffset);
    _drawTree(canvas, Offset(size.width * 0.85, size.height - 15), 18,
        -swayOffset * 0.7);
  }

  void _drawStars(Canvas canvas, Size size) {
    if (brightness == Brightness.light)
      return; // Stars are invisible on light backgrounds
    final starPaint = Paint()
      ..color = Colors.white.withValues(
          alpha: 0.45 + 0.4 * math.sin(animationValue * 2 * math.pi * 5));

    canvas.drawCircle(Offset(size.width * 0.08, 14), 1.0, starPaint);
    canvas.drawCircle(Offset(size.width * 0.22, 28), 1.2, starPaint);
    canvas.drawCircle(Offset(size.width * 0.45, 10), 0.9, starPaint);
    canvas.drawCircle(Offset(size.width * 0.68, 25), 1.4, starPaint);
    canvas.drawCircle(Offset(size.width * 0.35, 35), 0.8, starPaint);
  }

  void _drawConstellations(Canvas canvas, Size size) {
    if (brightness == Brightness.light) return;
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(size.width * 0.08, 14),
        Offset(size.width * 0.22, 28), linePaint);
    canvas.drawLine(Offset(size.width * 0.22, 28),
        Offset(size.width * 0.35, 35), linePaint);
    canvas.drawLine(Offset(size.width * 0.35, 35),
        Offset(size.width * 0.45, 10), linePaint);
  }

  void _drawShootingStar(Canvas canvas, Size size) {
    if (brightness == Brightness.light) return;
    final double starProgress = (animationValue * 3.5) % 4;
    if (starProgress < 1.0) {
      final startX = size.width * 0.55;
      final startY = -12.0;
      final delta = starProgress * 65;

      final trailPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.85),
            Colors.white.withValues(alpha: 0.0)
          ],
        ).createShader(Rect.fromLTWH(startX - delta, startY + delta, 20, 20))
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(startX - delta + 12, startY + delta - 12),
        Offset(startX - delta, startY + delta),
        trailPaint,
      );
    }
  }

  void _drawDayBirds(Canvas canvas, Size size) {
    final birdPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    // First bird
    double bird1X = (size.width * 0.15) + (animationValue * 45);
    if (bird1X > size.width + 10) bird1X = -10;
    final wing1Angle = math.sin(animationValue * 2 * math.pi * 8) * 3;
    final path1 = Path();
    path1.moveTo(bird1X - 3.5, 14 - wing1Angle);
    path1.quadraticBezierTo(bird1X - 1.8, 12, bird1X, 14);
    path1.quadraticBezierTo(bird1X + 1.8, 12, bird1X + 3.5, 14 - wing1Angle);
    canvas.drawPath(path1, birdPaint);

    // Second bird flying slightly offset
    double bird2X = (size.width * 0.38) + (animationValue * 38);
    if (bird2X > size.width + 10) bird2X = -10;
    final wing2Angle = math.cos(animationValue * 2 * math.pi * 8) * 2.5;
    final path2 = Path();
    path2.moveTo(bird2X - 3.0, 18 - wing2Angle);
    path2.quadraticBezierTo(bird2X - 1.5, 16.5, bird2X, 18);
    path2.quadraticBezierTo(bird2X + 1.5, 16.5, bird2X + 3.0, 18 - wing2Angle);
    canvas.drawPath(path2, birdPaint);
  }

  void _drawLightShafts(Canvas canvas, Size size) {
    final shaftPaint = Paint()
      ..color = Colors.amber.withValues(
          alpha: 0.05 + 0.03 * math.sin(animationValue * 2 * math.pi * 2))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width - 25, 20);
    path.lineTo(size.width * 0.4, size.height);
    path.lineTo(size.width * 0.5, size.height);
    path.close();
    canvas.drawPath(path, shaftPaint);
  }

  void _drawCloud(Canvas canvas, Offset center, double width) {
    final baseColor = isDayTime
        ? Colors.white.withValues(alpha: 0.35)
        : (brightness == Brightness.light
            ? Colors.grey.withValues(alpha: 0.15)
            : primaryColor.withValues(alpha: 0.06));

    final shadowColor = isDayTime
        ? Colors.white.withValues(alpha: 0.45)
        : (brightness == Brightness.light
            ? Colors.grey.withValues(alpha: 0.25)
            : primaryColor.withValues(alpha: 0.12));

    // Shadow Layer
    final shadowPaint = Paint()..color = shadowColor;
    canvas.drawCircle(
        center + const Offset(1.5, 1.5), width * 0.5, shadowPaint);
    canvas.drawCircle(center + Offset(-width * 0.35 + 1.5, width * 0.1 + 1.5),
        width * 0.35, shadowPaint);
    canvas.drawCircle(center + Offset(width * 0.35 + 1.5, width * 0.1 + 1.5),
        width * 0.35, shadowPaint);

    // Base Layer
    final cloudPaint = Paint()..color = baseColor;
    canvas.drawCircle(center, width * 0.5, cloudPaint);
    canvas.drawCircle(
        center + Offset(-width * 0.35, width * 0.1), width * 0.35, cloudPaint);
    canvas.drawCircle(
        center + Offset(width * 0.35, width * 0.1), width * 0.35, cloudPaint);
    canvas.drawRect(
      Rect.fromLTRB(
        center.dx - width * 0.5,
        center.dy,
        center.dx + width * 0.5,
        center.dy + width * 0.4,
      ),
      cloudPaint,
    );
  }

  void _drawTree(Canvas canvas, Offset base, double height, double sway) {
    final trunkColor = isDayTime
        ? const Color(0xFF5D4037)
        : (brightness == Brightness.light
            ? const Color(0xFF8D6E63)
            : (isAmoled ? const Color(0xFF16123F) : const Color(0xFF1D1743)));
    final trunkPaint = Paint()..color = trunkColor;

    final trunkPath = Path();
    trunkPath.moveTo(base.dx - 1.2, base.dy);
    trunkPath.lineTo(base.dx + 1.2, base.dy);
    trunkPath.lineTo(base.dx + 0.9 + (sway * 0.1), base.dy - height * 0.3);
    trunkPath.lineTo(base.dx - 0.9 + (sway * 0.1), base.dy - height * 0.3);
    trunkPath.close();
    canvas.drawPath(trunkPath, trunkPaint);

    final leafColor = isDayTime
        ? const Color(0xFF4CAF50)
        : (brightness == Brightness.light
            ? primaryColor.withValues(alpha: 0.6)
            : (isAmoled ? const Color(0xFF3F32B0) : const Color(0xFF5B4BD8)));
    final highlightColor = isDayTime
        ? const Color(0xFF81C784)
        : (brightness == Brightness.light
            ? primaryColor.withValues(alpha: 0.8)
            : (isAmoled ? const Color(0xFF594AD3) : const Color(0xFF7E73FF)));

    final leafPaint = Paint()..color = leafColor;
    final leafPath = Path();
    leafPath.moveTo(base.dx + sway, base.dy - height);
    leafPath.lineTo(
        base.dx - height * 0.32 + (sway * 0.3), base.dy - height * 0.3);
    leafPath.lineTo(
        base.dx + height * 0.32 + (sway * 0.3), base.dy - height * 0.3);
    leafPath.close();
    canvas.drawPath(leafPath, leafPaint);

    final highlightPaint = Paint()..color = highlightColor;
    final highlightPath = Path();
    highlightPath.moveTo(base.dx + sway, base.dy - height);
    highlightPath.lineTo(base.dx + (sway * 0.3), base.dy - height * 0.3);
    highlightPath.lineTo(
        base.dx + height * 0.32 + (sway * 0.3), base.dy - height * 0.3);
    highlightPath.close();
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

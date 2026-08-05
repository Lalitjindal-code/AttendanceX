import 'package:flutter/material.dart';

class HeaderIllustration extends StatelessWidget {
  const HeaderIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(140, 80),
      painter: _NightSkyPainter(),
    );
  }
}

class _NightSkyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // We will paint a simplified version of the illustration:
    // A soft gradient glow, some hills, a moon, and a couple of trees.
    
    // 1. Draw glowing moon
    final moonCenter = Offset(size.width - 30, 20);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF6B4EE6).withValues(alpha: 0.5),
          const Color(0xFF6B4EE6).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: 24));
    canvas.drawCircle(moonCenter, 24, glowPaint);
    
    final moonPaint = Paint()
      ..color = const Color(0xFF8C7CFF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(moonCenter, 8, moonPaint);
    
    // Moon inner highlight
    final moonHighlight = Paint()..color = Colors.white.withValues(alpha: 0.3);
    canvas.drawCircle(moonCenter + const Offset(-2, -2), 3, moonHighlight);

    // 2. Draw hills (Path)
    final backHillPath = Path();
    backHillPath.moveTo(0, size.height);
    backHillPath.quadraticBezierTo(
        size.width * 0.25, size.height - 20, size.width * 0.5, size.height - 5);
    backHillPath.quadraticBezierTo(
        size.width * 0.75, size.height - 30, size.width, size.height - 10);
    backHillPath.lineTo(size.width, size.height);
    backHillPath.close();

    final backHillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF2A2362),
          const Color(0xFF0F0F23).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(backHillPath, backHillPaint);

    final frontHillPath = Path();
    frontHillPath.moveTo(0, size.height);
    frontHillPath.quadraticBezierTo(
        size.width * 0.2, size.height - 5, size.width * 0.4, size.height - 15);
    frontHillPath.quadraticBezierTo(
        size.width * 0.6, size.height, size.width * 0.8, size.height - 15);
    frontHillPath.lineTo(size.width, size.height);
    frontHillPath.close();

    final frontHillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF4334A1),
          const Color(0xFF0B0B13).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(frontHillPath, frontHillPaint);

    // 3. Draw a tree
    _drawTree(canvas, Offset(size.width * 0.15, size.height - 10), 20);
    _drawTree(canvas, Offset(size.width * 0.85, size.height - 15), 16);
  }

  void _drawTree(Canvas canvas, Offset base, double height) {
    // Trunk
    final trunkPaint = Paint()..color = const Color(0xFF1D1743);
    canvas.drawRect(
        Rect.fromLTWH(base.dx - 1, base.dy - height * 0.3, 2, height * 0.3),
        trunkPaint);

    // Leaves
    final leafPaint = Paint()..color = const Color(0xFF5B4BD8);
    final leafPath = Path();
    leafPath.moveTo(base.dx, base.dy - height);
    leafPath.lineTo(base.dx - height * 0.3, base.dy - height * 0.3);
    leafPath.lineTo(base.dx + height * 0.3, base.dy - height * 0.3);
    leafPath.close();
    canvas.drawPath(leafPath, leafPaint);
    
    // Highlight
    final highlightPaint = Paint()..color = const Color(0xFF7E73FF);
    final highlightPath = Path();
    highlightPath.moveTo(base.dx, base.dy - height);
    highlightPath.lineTo(base.dx, base.dy - height * 0.3);
    highlightPath.lineTo(base.dx + height * 0.3, base.dy - height * 0.3);
    highlightPath.close();
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

class Grid3DPainter extends CustomPainter {
  final double animationValue;

  Grid3DPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width;
    final height = size.height;

    // Define Paints
    final gridPaint = Paint()
      ..color = const Color(0xFF00D1FF).withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final roadPaint = Paint()
      ..color = const Color(0xFF00FFB2).withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final buildingPaint = Paint()
      ..color = const Color(0xFF7B61FF).withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final lightBeamPaint = Paint()
      ..color = const Color(0xFF00D1FF).withOpacity(0.04)
      ..style = PaintingStyle.fill;

    // 1. Draw Horizon Line & Fade Gradient
    final horizon = height * 0.45;
    
    // Draw background horizon glow
    final bgGlow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF050816),
          const Color(0xFF0B1120).withOpacity(0.9),
        ],
      ).createShader(Rect.fromLTRB(0, 0, width, height));
    canvas.drawRect(Rect.fromLTRB(0, 0, width, height), bgGlow);

    // 2. Perspective Projection Function
    Offset project(double x, double y, double z) {
      // Perspective matrix approximation
      // z is depth (from horizon to bottom of screen)
      final scale = 1.0 / (z + 0.1);
      final px = center.dx + x * scale * width * 0.5;
      final py = horizon + (y + 0.25) * scale * height * 0.5;
      return Offset(px, py);
    }

    // 3. Draw Perspective Grid Lines
    // Longitudinal lines (radiating from horizon center)
    const lineCount = 20;
    for (int i = 0; i <= lineCount; i++) {
      final ratio = (i / lineCount) * 2 - 1; // -1 to 1
      final xStart = ratio * 12.0; // Wide at the bottom
      
      final pStart = project(xStart, 0.4, 0.2);
      final pEnd = project(xStart * 0.05, 0.0, 4.0); // Converge at horizon
      
      canvas.drawLine(pStart, pEnd, gridPaint);
    }

    // Transverse lines (horizontal scrolling lines)
    final scrollOffset = animationValue % 1.0;
    const horizontalLines = 15;
    for (int i = 0; i < horizontalLines; i++) {
      final zDepth = (i + scrollOffset) * 0.25;
      
      final leftPoint = project(-6.0, 0.4, zDepth);
      final rightPoint = project(6.0, 0.4, zDepth);

      // Fade out as lines get closer to the horizon
      final opacity = (1.0 - (zDepth / 3.0)).clamp(0.0, 1.0) * 0.08;
      canvas.drawLine(
        leftPoint, 
        rightPoint, 
        Paint()
          ..color = const Color(0xFF00D1FF).withOpacity(opacity)
          ..strokeWidth = 1.0
      );
    }

    // 4. Draw Center Glowing Smart Grid Roads (Highways)
    final roadScroll = (animationValue * 1.5) % 1.0;
    for (int r = -1; r <= 1; r += 2) {
      final roadX = r * 1.8;
      
      final roadStart = project(roadX, 0.39, 0.15);
      final roadEnd = project(roadX * 0.05, 0.0, 4.0);
      canvas.drawLine(roadStart, roadEnd, roadPaint);

      // Floating Traffic Neon Particles
      for (int i = 0; i < 4; i++) {
        final tDepth = ((i + roadScroll) / 4) * 3.5;
        if (tDepth > 3.0) continue;
        
        final tOffset = project(roadX * (1.0 - tDepth / 3.5), 0.38, tDepth);
        final tSize = (8.0 * (1.0 - tDepth / 3.5)).clamp(1.5, 6.0);
        
        canvas.drawCircle(
          tOffset, 
          tSize, 
          Paint()
            ..color = r == -1 ? const Color(0xFF00FFB2) : const Color(0xFF00D1FF)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0)
        );
      }
    }

    // 5. Draw 3D Skyscraper Wireframes
    // Fixed Random Seeded Buildings
    final random = math.Random(101);
    for (int i = 0; i < 16; i++) {
      final side = random.nextBool() ? 1.0 : -1.0;
      final bX = side * (2.8 + random.nextDouble() * 3.0);
      final bZ = 0.5 + random.nextDouble() * 2.5;

      final bWidth = 0.2 + random.nextDouble() * 0.35;
      final bHeight = 0.4 + random.nextDouble() * 1.2;

      // Vertical wireframe coordinates
      final left = bX - bWidth / 2;
      final right = bX + bWidth / 2;
      final bYTop = -bHeight;
      final bYBase = 0.4;

      // Vertices
      final vBaseLeft = project(left, bYBase, bZ);
      final vBaseRight = project(right, bYBase, bZ);
      final vTopLeft = project(left, bYTop, bZ);
      final vTopRight = project(right, bYTop, bZ);

      final vBaseBackLeft = project(left, bYBase, bZ + 0.25);
      final vBaseBackRight = project(project(right, bYBase, bZ + 0.25).dx, project(right, bYBase, bZ + 0.25).dy, bZ + 0.25); // simple depth offset
      final vTopBackLeft = project(left, bYTop, bZ + 0.25);
      final vTopBackRight = project(right, bYTop, bZ + 0.25);

      final fadeFactor = (1.0 - (bZ / 3.0)).clamp(0.05, 0.85);
      final customBuildingPaint = Paint()
        ..color = (side == 1.0 ? const Color(0xFF7B61FF) : const Color(0xFF00D1FF)).withOpacity(fadeFactor * 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;

      // Draw wireframe panels
      // Base Front Rect
      canvas.drawLine(vBaseLeft, vBaseRight, customBuildingPaint);
      canvas.drawLine(vBaseRight, vTopRight, customBuildingPaint);
      canvas.drawLine(vTopRight, vTopLeft, customBuildingPaint);
      canvas.drawLine(vTopLeft, vBaseLeft, customBuildingPaint);

      // Back Rect
      canvas.drawLine(vBaseBackLeft, vBaseBackRight, customBuildingPaint);
      canvas.drawLine(vBaseBackRight, vTopBackRight, customBuildingPaint);
      canvas.drawLine(vTopBackRight, vTopBackLeft, customBuildingPaint);
      canvas.drawLine(vTopBackLeft, vBaseBackLeft, customBuildingPaint);

      // Connector edges
      canvas.drawLine(vBaseLeft, vBaseBackLeft, customBuildingPaint);
      canvas.drawLine(vBaseRight, vBaseBackRight, customBuildingPaint);
      canvas.drawLine(vTopLeft, vTopBackLeft, customBuildingPaint);
      canvas.drawLine(vTopRight, vTopBackRight, customBuildingPaint);

      // Draw glowing light beams straight up from select tall buildings
      if (i % 5 == 0) {
        final beamPath = Path()
          ..moveTo(vTopLeft.dx, vTopLeft.dy)
          ..lineTo(vTopRight.dx, vTopRight.dy)
          ..lineTo(vTopRight.dx - 15, vTopRight.dy - 120)
          ..lineTo(vTopLeft.dx + 15, vTopLeft.dy - 120)
          ..close();
        canvas.drawPath(beamPath, lightBeamPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant Grid3DPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

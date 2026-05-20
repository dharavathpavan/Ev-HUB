import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class Charger3DPainter extends CustomPainter {
  final double animationValue;
  final bool isHovered;

  Charger3DPainter({
    required this.animationValue,
    required this.isHovered,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = math.min(size.width, size.height) * 0.4;
    final speedMultiplier = isHovered ? 2.5 : 1.0;
    final angle = animationValue * 2 * math.pi * speedMultiplier;

    // Define Paints
    final cabinetPaint = Paint()
      ..color = const Color(0xFF0B1120).withOpacity(0.9)
      ..style = PaintingStyle.fill;

    final wireframePaint = Paint()
      ..color = const Color(0xFF00D1FF).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final glowPaint = Paint()
      ..color = isHovered ? const Color(0xFF00FFB2) : const Color(0xFF00D1FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final coreGlowPaint = Paint()
      ..color = isHovered 
          ? const Color(0xFF00FFB2).withOpacity(0.3) 
          : const Color(0xFF7B61FF).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final particlePaint = Paint()
      ..color = const Color(0xFF00FFB2).withOpacity(0.8)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // 1. Draw Holographic Circular Base Indicator (Grid Rings)
    final basePulse = 1.0 + math.sin(animationValue * 4 * math.pi) * 0.05;
    for (int i = 0; i < 3; i++) {
      final ringRadius = baseRadius * (0.8 + i * 0.2) * basePulse;
      final path = Path();
      for (int a = 0; a <= 360; a += 10) {
        final rad = a * math.pi / 180;
        final x = center.dx + math.cos(rad) * ringRadius;
        final y = center.dy + size.height * 0.3 + math.sin(rad) * ringRadius * 0.3; // Perspective flatten
        if (a == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, Paint()
        ..color = const Color(0xFF00FFB2).withOpacity(0.15 - i * 0.04)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
    }

    // 2. Draw 3D Cabinet Box (Isometric Perspective Projection)
    final cabinetHeight = baseRadius * 1.8;
    final cabinetWidth = baseRadius * 0.7;
    final cabinetDepth = baseRadius * 0.25;

    // Calculate Cabinet Vertices based on Y-Rotation
    final rotationY = angle * 0.1; // Slow rotation
    
    Offset project(double x, double y, double z) {
      // Basic 3D Y-rotation matrix
      final rx = x * math.cos(rotationY) - z * math.sin(rotationY);
      final rz = x * math.sin(rotationY) + z * math.cos(rotationY);
      // Perspective scale factor
      final scale = 1.0 / (1.0 + rz * 0.001);
      return Offset(center.dx + rx * scale, center.dy + y * scale);
    }

    // Cabinet vertices (Center is middle of cabinet)
    final halfW = cabinetWidth / 2;
    final halfH = cabinetHeight / 2;
    final halfD = cabinetDepth / 2;

    // Bottom 4 vertices
    final v0 = project(-halfW, halfH, -halfD);
    final v1 = project(halfW, halfH, -halfD);
    final v2 = project(halfW, halfH, halfD);
    final v3 = project(-halfW, halfH, halfD);

    // Top 4 vertices
    final v4 = project(-halfW, -halfH, -halfD);
    final v5 = project(halfW, -halfH, -halfD);
    final v6 = project(halfW, -halfH, halfD);
    final v7 = project(-halfW, -halfH, halfD);

    // Draw solid back faces
    final Map<int, List<Offset>> faces = {
      0: [v0, v1, v5, v4], // Front
      1: [v1, v2, v6, v5], // Right
      2: [v2, v3, v7, v6], // Back
      3: [v3, v0, v4, v7], // Left
      4: [v4, v5, v6, v7], // Top
      5: [v0, v1, v2, v3], // Bottom
    };

    // Simple painter depth sort (simulate Z-buffer)
    // Draw solid panels
    for (final face in faces.values) {
      final path = Path()
        ..moveTo(face[0].dx, face[0].dy)
        ..lineTo(face[1].dx, face[1].dy)
        ..lineTo(face[2].dx, face[2].dy)
        ..lineTo(face[3].dx, face[3].dy)
        ..close();
      canvas.drawPath(path, cabinetPaint);
      canvas.drawPath(path, wireframePaint);
    }

    // 3. Draw Volumetric Glowing Light Bars on Cabinet Edges
    final neonLeftBottom = project(-halfW - 4, -halfH * 0.8, -halfD - 2);
    final neonLeftTop = project(-halfW - 4, halfH * 0.8, -halfD - 2);
    canvas.drawLine(neonLeftBottom, neonLeftTop, glowPaint);

    final neonRightBottom = project(halfW + 4, -halfH * 0.8, -halfD - 2);
    final neonRightTop = project(halfW + 4, halfH * 0.8, -halfD - 2);
    canvas.drawLine(neonRightBottom, neonRightTop, Paint()
      ..color = const Color(0xFF00FFB2)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke);

    // 4. Draw Glowing Energy Sphere inside the center
    final coreCenter = project(0, -halfH * 0.1, 0);
    final corePulse = 1.0 + math.sin(animationValue * 6 * math.pi) * 0.1;
    final coreRadius = baseRadius * 0.22 * corePulse;

    // Draw glow radial effect
    canvas.drawCircle(coreCenter, coreRadius * 1.5, coreGlowPaint);
    
    // Draw wireframe orbital sphere
    final spherePath = Path();
    final spherePoints = <Offset>[];
    for (double lat = -math.pi / 2; lat <= math.pi / 2; lat += math.pi / 6) {
      for (double lon = 0; lon <= 2 * math.pi; lon += math.pi / 6) {
        final x = coreRadius * math.cos(lat) * math.cos(lon + animationValue * math.pi);
        final y = -halfH * 0.1 + coreRadius * math.sin(lat);
        final z = coreRadius * math.cos(lat) * math.sin(lon + animationValue * math.pi);
        spherePoints.add(project(x, y, z));
      }
    }
    
    for (int i = 0; i < spherePoints.length - 1; i++) {
      canvas.drawCircle(spherePoints[i], 1.2, Paint()..color = const Color(0xFF00D1FF).withOpacity(0.5));
    }

    // 5. Draw Dynamic Orbiting Rings (Holographic Toruses)
    final ring1Radius = baseRadius * 0.45;
    final ring2Radius = baseRadius * 0.55;

    void drawOrbitRing(double rotX, double rotY, Color color) {
      final ringPoints = <Offset>[];
      for (int a = 0; a <= 360; a += 10) {
        final rad = a * math.pi / 180;
        // Apply 3D orbit formula
        final lx = ring1Radius * math.cos(rad);
        final ly = ring1Radius * math.sin(rad) * math.cos(rotX) + -halfH * 0.1;
        final lz = ring1Radius * math.sin(rad) * math.sin(rotX);
        
        // Rotate Lon
        final rx = lx * math.cos(rotY) - lz * math.sin(rotY);
        final ry = ly;
        final rz = lx * math.sin(rotY) + lz * math.cos(rotY);

        ringPoints.add(project(rx, ry, rz));
      }

      final ringPath = Path()..moveTo(ringPoints[0].dx, ringPoints[0].dy);
      for (int i = 1; i < ringPoints.length; i++) {
        ringPath.lineTo(ringPoints[i].dx, ringPoints[i].dy);
      }
      canvas.drawPath(ringPath, Paint()
        ..color = color.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
    }

    drawOrbitRing(0.5, angle * 0.3, const Color(0xFF00D1FF));
    drawOrbitRing(-0.7, -angle * 0.2, const Color(0xFF7B61FF));

    // 6. Draw Volumetric Floating Particle Orbs inside and outside
    final random = math.Random(42); // Seeded
    for (int i = 0; i < 24; i++) {
      final pRad = baseRadius * (0.3 + random.nextDouble() * 0.8);
      final pAngle = random.nextDouble() * 2 * math.pi + animationValue * 0.5 * (random.nextBool() ? 1 : -1);
      final pY = -halfH * 0.8 + random.nextDouble() * cabinetHeight * 0.8;
      
      final px = pRad * math.cos(pAngle);
      final pz = pRad * math.sin(pAngle);
      final py = pY;

      final pOffset = project(px, py, pz);
      
      // Calculate opacity based on Z-depth (parallax)
      final zDepth = px * math.sin(rotationY) + pz * math.cos(rotationY);
      final pOpacity = ((zDepth + baseRadius) / (2 * baseRadius)).clamp(0.1, 0.9);

      canvas.drawPoints(
        PointMode.points, 
        [pOffset], 
        particlePaint..color = const Color(0xFF00FFB2).withOpacity(pOpacity)
      );
    }
  }

  @override
  bool shouldRepaint(covariant Charger3DPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.isHovered != isHovered;
  }
}

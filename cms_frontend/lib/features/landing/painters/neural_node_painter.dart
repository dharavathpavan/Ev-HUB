import 'dart:math' as math;
import 'package:flutter/material.dart';

class NeuralNodePainter extends CustomPainter {
  final double animationValue;

  NeuralNodePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Define Paints
    final nodePaint = Paint()
      ..color = const Color(0xFF00FFB2)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = const Color(0xFF00D1FF).withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final activeLinePaint = Paint()
      ..color = const Color(0xFF00FFB2).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 1. Setup Static Seeded Node Locations
    final random = math.Random(1337);
    final nodes = <Offset>[];
    final nodeSizes = <double>[];
    
    const nodeCount = 35;
    for (int i = 0; i < nodeCount; i++) {
      // Floating offset based on animation
      final basePercentX = random.nextDouble();
      final basePercentY = random.nextDouble();
      
      final driftAngle = animationValue * 2 * math.pi + (random.nextDouble() * 10.0);
      final driftDistance = 8.0 + random.nextDouble() * 12.0;
      
      final dx = basePercentX * width + math.cos(driftAngle) * driftDistance;
      final dy = basePercentY * height + math.sin(driftAngle) * driftDistance;
      
      nodes.add(Offset(dx, dy));
      nodeSizes.add(3.0 + random.nextDouble() * 4.0);
    }

    // 2. Draw Interconnecting Vectors (Vector Lines)
    // Draw lines between nodes if they are within a threshold distance
    final threshold = math.min(width, height) * 0.22;
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final dist = (nodes[i] - nodes[j]).distance;
        if (dist < threshold) {
          // Draw connecting line
          final factor = (1.0 - (dist / threshold)).clamp(0.0, 1.0);
          
          // Animate pulsing links selectively
          final isPulsing = (i + j) % 7 == 0;
          if (isPulsing) {
            canvas.drawLine(
              nodes[i], 
              nodes[j], 
              activeLinePaint..color = const Color(0xFF00FFB2).withOpacity(factor * 0.35)
            );
            
            // Draw floating packets along active lines
            final packetProgress = (animationValue * 1.5 + (i * 0.1)) % 1.0;
            final packetPos = Offset.lerp(nodes[i], nodes[j], packetProgress)!;
            canvas.drawCircle(
              packetPos, 
              2.5, 
              Paint()
                ..color = const Color(0xFF00FFB2)
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0)
            );
          } else {
            canvas.drawLine(
              nodes[i], 
              nodes[j], 
              linePaint..color = const Color(0xFF00D1FF).withOpacity(factor * 0.15)
            );
          }
        }
      }
    }

    // 3. Draw Nodes (Glow circles and outer rings)
    for (int i = 0; i < nodes.length; i++) {
      final pos = nodes[i];
      final r = nodeSizes[i];
      
      // Node Pulse base
      final pulse = 1.0 + math.sin(animationValue * 5 * math.pi + i) * 0.15;
      
      // Glow boundary
      canvas.drawCircle(
        pos, 
        r * 2.5 * pulse, 
        Paint()
          ..color = (i % 3 == 0 ? const Color(0xFF7B61FF) : const Color(0xFF00FFB2)).withOpacity(0.08)
          ..style = PaintingStyle.fill
      );

      // Solid Node Center
      canvas.drawCircle(
        pos, 
        r * pulse, 
        nodePaint..color = (i % 3 == 0 ? const Color(0xFF7B61FF) : const Color(0xFF00FFB2))
      );

      // Hollow Rotating Ring Around Anchor Nodes
      if (i % 5 == 0) {
        canvas.drawCircle(
          pos, 
          r * 3.5 * pulse, 
          Paint()
            ..color = const Color(0xFF00D1FF).withOpacity(0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant NeuralNodePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

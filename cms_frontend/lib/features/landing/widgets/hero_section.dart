import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../painters/grid_3d_painter.dart';

class HeroSection extends StatefulWidget {
  final VoidCallback onExploreNetwork;

  const HeroSection({
    super.key,
    required this.onExploreNetwork,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Container(
      width: double.infinity,
      height: size.height,
      color: const Color(0xFF050816),
      child: Stack(
        children: [
          // 1. Perspective Cyber Grid Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: Grid3DPainter(animationValue: _controller.value),
                );
              },
            ),
          ),

          // 2. Horizon Shading Vignette
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF050816).withOpacity(0.4),
                    Colors.transparent,
                    const Color(0xFF050816).withOpacity(0.85),
                  ],
                ),
              ),
            ),
          ),

          // 3. 3D Charger Centerpiece (Positioned Right/Center depending on viewport)
          Positioned(
            right: isMobile ? 0 : size.width * 0.04,
            left: isMobile ? 0 : null,
            top: isMobile ? size.height * 0.48 : size.height * 0.08,
            bottom: isMobile ? 60 : size.height * 0.08,
            width: isMobile ? size.width : size.width * 0.46,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // Smooth volumetric floating animation using sine wave
                final floatOffset = math.sin(_controller.value * 2 * math.pi) * 12.0;
                return Transform.translate(
                  offset: Offset(0, floatOffset),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // High-fidelity background holographic radial glow
                      Container(
                        width: isMobile ? 240 : size.width * 0.32,
                        height: isMobile ? 240 : size.width * 0.32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF00FFB2).withOpacity(0.18),
                              const Color(0xFF00D1FF).withOpacity(0.04),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Premium 3D Charger Asset
                      Image.asset(
                        'assets/images/3d_charger.png',
                        fit: BoxFit.contain,
                        width: isMobile ? size.width * 0.75 : size.width * 0.38,
                        height: isMobile ? size.height * 0.38 : size.height * 0.75,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 4. Hero Content Overlay
          Positioned(
            left: isMobile ? 24 : size.width * 0.08,
            top: isMobile ? size.height * 0.1 : size.height * 0.22,
            width: isMobile ? size.width - 48 : size.width * 0.45,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Global Tech Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D1FF).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: const Color(0xFF00D1FF).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00FFB2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'GLOBAL CHARGING PLATFORM V2.0',
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: const Color(0xFF00D1FF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Headline
                Text(
                  'Powering The\nFuture Of EV',
                  style: GoogleFonts.orbitron(
                    fontSize: isMobile ? 40 : 68,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -1.0,
                    color: Colors.white,
                  ),
                ),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00D1FF), Color(0xFF00FFB2), Color(0xFF7B61FF)],
                  ).createShader(bounds),
                  child: Text(
                    'Mobility.',
                    style: GoogleFonts.orbitron(
                      fontSize: isMobile ? 40 : 68,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: -1.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Subtitle
                Text(
                  'Realtime electric charging ecosystem engineered for ultra-fast networks, CPO platforms, and smart city grids.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isMobile ? 15 : 18,
                    color: const Color(0xFF9CA3AF),
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),

                // Action Cluster Row
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    ElevatedButton(
                      onPressed: () => context.go('/dashboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FFB2),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'START CHARGING',
                            style: GoogleFonts.orbitron(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: widget.onExploreNetwork,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: const Color(0xFF00D1FF).withOpacity(0.4),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.public, size: 16, color: Color(0xFF00D1FF)),
                          const SizedBox(width: 8),
                          Text(
                            'EXPLORE NETWORK',
                            style: GoogleFonts.orbitron(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Small Telemetry Stats Row
                Row(
                  children: [
                    _buildHeroStat('99.98%', 'Cabinet Uptime'),
                    const SizedBox(width: 40),
                    _buildHeroStat('<150ms', 'OCPP Latency'),
                    const SizedBox(width: 40),
                    _buildHeroStat('450 kW', 'Max Power Draw'),
                  ],
                ),
              ],
            ),
          ),

          // Scroll Down indicator
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'SCROLL DOWN',
                  style: GoogleFonts.orbitron(
                    color: const Color(0xFF00D1FF).withOpacity(0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 2,
                  height: 35,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF00D1FF),
                        const Color(0xFF00D1FF).withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

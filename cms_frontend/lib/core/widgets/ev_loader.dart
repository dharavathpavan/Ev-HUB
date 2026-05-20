import 'package:flutter/material.dart';

class EVLoader extends StatefulWidget {
  final String text;
  const EVLoader({super.key, this.text = 'Connecting to Hardware...'});

  @override
  State<EVLoader> createState() => _EVLoaderState();
}

class _EVLoaderState extends State<EVLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fillAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Battery / Charging Icon Graphic
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Glow
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4ADDA2).withOpacity(_pulseAnimation.value * 0.4),
                          blurRadius: 30,
                          spreadRadius: _pulseAnimation.value * 10,
                        )
                      ],
                    ),
                  ),
                  // Battery outline
                  Container(
                    width: 60,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF2A2A2A), width: 4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Fill animation (green moving up)
                        FractionallySizedBox(
                          heightFactor: _fillAnimation.value,
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF4ADDA2).withOpacity(0.8),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        // Lightning bolt
                        const Center(
                          child: Icon(Icons.bolt, color: Colors.white, size: 40),
                        )
                      ],
                    ),
                  ),
                  // Battery Nub
                  Positioned(
                    top: -6,
                    child: Container(
                      width: 20,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                      ),
                    ),
                  )
                ],
              );
            }
          ),
          const SizedBox(height: 32),
          // Animated Text
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _pulseAnimation.value,
                child: Text(
                  widget.text,
                  style: const TextStyle(color: Color(0xFF4ADDA2), fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
              );
            }
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingNavbar extends StatelessWidget {
  final Function(String) onScrollToSection;
  final bool isScrolled;

  const LandingNavbar({
    super.key,
    required this.onScrollToSection,
    required this.isScrolled,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isScrolled 
            ? const Color(0xFF050816).withOpacity(0.85) 
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: isScrolled 
                ? const Color(0xFF00D1FF).withOpacity(0.1) 
                : Colors.transparent,
            width: 1.0,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width < 1200 ? 20 : 40,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Branding
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onScrollToSection('hero'),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D1FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF00D1FF).withOpacity(0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.bolt,
                      color: Color(0xFF00D1FF),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'HYPERION',
                    style: GoogleFonts.orbitron(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
 
          // Central Navigation Links (Desktop only)
          if (MediaQuery.of(context).size.width > 1000)
            Row(
              children: [
                _buildNavLink('Features', 'features'),
                _buildNavLink('Network', 'network'),
                _buildNavLink('Technology', 'technology'),
                _buildNavLink('Vendors', 'vendors'),
                _buildNavLink('Developers', 'developers'),
              ],
            ),

          // Quick Access Actions
          Row(
            children: [
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  'Login',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => context.go('/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D1FF).withOpacity(0.08),
                  foregroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  shadowColor: const Color(0xFF00D1FF).withOpacity(0.4),
                  elevation: 10,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: const BorderSide(
                      color: Color(0xFF00D1FF),
                      width: 1.0,
                    ),
                  ),
                ),
                child: Text(
                  'GET STARTED',
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(String label, String sectionId) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onScrollToSection(sectionId),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

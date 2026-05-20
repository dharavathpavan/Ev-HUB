import 'package:flutter/material.dart';
import '../widgets/landing_navbar.dart';
import '../widgets/hero_section.dart';
import '../widgets/landing_sections.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  // Global Keys for smooth scrolling to sections
  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _networkKey = GlobalKey();
  final GlobalKey _flowKey = GlobalKey();
  final GlobalKey _showcaseKey = GlobalKey();
  final GlobalKey _dashboardKey = GlobalKey();
  final GlobalKey _mobileKey = GlobalKey();
  final GlobalKey _vendorKey = GlobalKey();
  final GlobalKey _aiKey = GlobalKey();
  final GlobalKey _developerKey = GlobalKey();
  final GlobalKey _ctaKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 50) {
      if (!_isScrolled) {
        setState(() => _isScrolled = true);
      }
    } else {
      if (_isScrolled) {
        setState(() => _isScrolled = false);
      }
    }
  }

  void _scrollToSection(String sectionId) {
    GlobalKey? targetKey;
    switch (sectionId) {
      case 'hero':
        targetKey = _heroKey;
        break;
      case 'features':
        targetKey = _flowKey;
        break;
      case 'network':
        targetKey = _networkKey;
        break;
      case 'technology':
        targetKey = _dashboardKey;
        break;
      case 'vendors':
        targetKey = _vendorKey;
        break;
      case 'developers':
        targetKey = _developerKey;
        break;
    }

    if (targetKey != null && targetKey.currentContext != null) {
      Scrollable.ensureVisible(
        targetKey.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      body: Stack(
        children: [
          // 1. Core Scrollable Sections
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  HeroSection(
                    key: _heroKey,
                    onExploreNetwork: () => _scrollToSection('network'),
                  ),
                  NetworkSection(key: _networkKey),
                  ChargingFlowSection(key: _flowKey),
                  ChargerShowcaseSection(key: _showcaseKey),
                  RealtimeDashboardSection(key: _dashboardKey),
                  MobileAppSection(key: _mobileKey),
                  VendorFleetSection(key: _vendorKey),
                  EnergyIntelligenceSection(key: _aiKey),
                  DeveloperApiSection(key: _developerKey),
                  FinalCtaSection(key: _ctaKey),
                  const LandingFooter(),
                ],
              ),
            ),
          ),

          // 2. Fixed Overlay Navigation Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LandingNavbar(
              onScrollToSection: _scrollToSection,
              isScrolled: _isScrolled,
            ),
          ),
        ],
      ),
    );
  }
}

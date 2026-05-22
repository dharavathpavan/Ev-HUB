import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:ui';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:cms_frontend/config.dart';
import '../widgets/glass_text_field.dart';
import '../widgets/animated_card_border.dart';

class VendorRegistrationScreen extends StatefulWidget {
  const VendorRegistrationScreen({super.key});

  @override
  State<VendorRegistrationScreen> createState() => _VendorRegistrationScreenState();
}

class _VendorRegistrationScreenState extends State<VendorRegistrationScreen> with TickerProviderStateMixin {
  late AnimationController _bgController;
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _taxIdController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  // 3D Card Physics
  double _mouseX = 0;
  double _mouseY = 0;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _businessNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _taxIdController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleRegistration() async {
    final businessName = _businessNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final taxId = _taxIdController.text.trim();
    final companyAddress = _addressController.text.trim();
    final phone = _phoneController.text.trim();

    if (businessName.isEmpty || email.isEmpty || password.isEmpty || companyAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'business_name': businessName,
          'role': 'vendor',
        },
      );

      if (result.user == null) {
        throw const AuthException('Vendor signup failed. Please try again.');
      }

      // Synchronize application with local Next.js DB. Wrap in sub-try/catch so that if Next.js backend
      // is not running/accessible, registration still completes (since Supabase auth succeeded).
      try {
        await http.post(
          Uri.parse('${Config.apiBaseUrl}/api/vendors/apply'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'business_name': businessName,
            'contact_email': email,
            'tax_id': taxId,
            'company_address': companyAddress,
            'phone_number': phone,
            'utility_bill_url': '',
            'estimated_chargers': 0
          }),
        ).timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('Warning: Local application database synchronization failed: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Note: Server database sync pending ($e). Account created successfully!'),
              backgroundColor: Colors.orangeAccent,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
      
      if (mounted) {
        setState(() => _isLoading = false);
        if (result.session != null) {
          context.go('/vendor-dashboard');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created. Please sign in to open your vendor dashboard.'),
              backgroundColor: Color(0xFF4ADDA2),
            ),
          );
          context.go('/login');
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: MouseRegion(
        onHover: (event) {
          final center = Offset(size.width / 2, size.height / 2);
          setState(() {
            _mouseX = ((event.position.dx - center.dx) / center.dx) * 0.08;
            _mouseY = ((event.position.dy - center.dy) / center.dy) * -0.08;
          });
        },
        onExit: (event) {
          setState(() {
            _mouseX = 0;
            _mouseY = 0;
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Gradient
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0x669C27B0), Color(0x807B1FA2), Colors.black],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Ambient Glowing Orbs
            AnimatedBuilder(
              animation: _bgController,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      top: -100,
                      left: size.width / 2 - 400,
                      child: Transform.scale(
                        scale: 0.98 + (_bgController.value * 0.04),
                        child: Opacity(
                          opacity: 0.15 + (_bgController.value * 0.15),
                          child: Container(
                            width: 800,
                            height: 400,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE1BEE7),
                              shape: BoxShape.circle,
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                              child: const SizedBox(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -200,
                      left: size.width / 2 - 300,
                      child: Transform.scale(
                        scale: 1.0 + (math.sin(_bgController.value * math.pi) * 0.1),
                        child: Opacity(
                          opacity: 0.3 + (math.sin(_bgController.value * math.pi) * 0.2),
                          child: Container(
                            width: 600,
                            height: 600,
                            decoration: const BoxDecoration(
                              color: Color(0xFFCE93D8),
                              shape: BoxShape.circle,
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                              child: const SizedBox(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // 3D Glassmorphic Card
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, double opacity, child) {
                return Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - opacity)),
                    child: child,
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(_mouseY)
                  ..rotateY(_mouseX),
                transformAlignment: Alignment.center,
                child: SizedBox(
                  width: 420,
                  child: AnimatedCardBorder(
                    borderWidth: 1.5,
                    borderRadius: BorderRadius.circular(20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.all(36),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Header
                              const Text(
                                'Become a Partner',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Register your CPO business to host stations',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),

                              // Inputs
                              GlassTextField(
                                hintText: 'Business / Company Name',
                                prefixIcon: Icons.business_outlined,
                                controller: _businessNameController,
                              ),
                              const SizedBox(height: 16),
                              GlassTextField(
                                hintText: 'Work Email address',
                                prefixIcon: Icons.mail_outline,
                                controller: _emailController,
                              ),
                              const SizedBox(height: 16),
                              GlassTextField(
                                hintText: 'Create Password',
                                prefixIcon: Icons.lock_outline,
                                isPassword: true,
                                controller: _passwordController,
                              ),
                              const SizedBox(height: 16),
                              GlassTextField(
                                hintText: 'Tax ID / GSTIN',
                                prefixIcon: Icons.receipt_long_outlined,
                                controller: _taxIdController,
                              ),
                              const SizedBox(height: 16),
                              GlassTextField(
                                hintText: 'Company Address',
                                prefixIcon: Icons.location_on_outlined,
                                controller: _addressController,
                              ),
                              const SizedBox(height: 16),
                              GlassTextField(
                                hintText: 'Phone Number',
                                prefixIcon: Icons.phone_outlined,
                                controller: _phoneController,
                              ),
                              const SizedBox(height: 32),
                              
                              // Register Button
                              InkWell(
                                onTap: _isLoading ? null : _handleRegistration,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 44,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.2),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      )
                                    ],
                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Create Account',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(Icons.arrow_forward, color: Colors.black, size: 16),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Sign In Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account? ",
                                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                                  ),
                                  TextButton(
                                    onPressed: () => context.go('/login'),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Sign in',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

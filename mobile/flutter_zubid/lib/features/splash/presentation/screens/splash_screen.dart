import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/storage_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _logoRotationAnimation;
  
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;
  
  late Animation<Color?> _backgroundColorAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));
    
    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    ));
    
    _logoRotationAnimation = Tween<double>(
      begin: -0.5,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
    ));

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
    ));
    
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    // Background animation
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _backgroundColorAnimation = ColorTween(
      begin: const Color(0xFF1A237E), // Deep blue
      end: const Color(0xFF3F51B5), // Indigo
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimationSequence() async {
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF1A237E),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // Start background animation
    _backgroundController.forward();
    
    // Start logo animation after a short delay
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    
    // Start text animation after logo starts
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
    
    // Navigate after all animations complete
    await Future.delayed(const Duration(milliseconds: 3500));
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    if (!mounted) return;
    
    try {
      // Check if user is logged in
      final token = await StorageService.getAuthToken();
      final authState = ref.read(authProvider);
      
      if (token != null && authState.user != null) {
        // User is logged in, go to home
        if (mounted) {
          context.go('/home');
        }
      } else {
        // User not logged in, go to login
        if (mounted) {
          context.go('/login');
        }
      }
    } catch (e) {
      // Error occurred, go to login
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundColorAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _backgroundColorAnimation.value ?? const Color(0xFF1A237E),
                  const Color(0xFF283593),
                  const Color(0xFF3949AB),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Top spacer
                  const Expanded(flex: 2, child: SizedBox()),
                  
                  // Logo section
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScaleAnimation.value,
                            child: Transform.rotate(
                              angle: _logoRotationAnimation.value,
                              child: Opacity(
                                opacity: _logoOpacityAnimation.value,
                                child: _buildLogo(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  // Text section
                  Expanded(
                    flex: 2,
                    child: AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _textSlideAnimation,
                          child: FadeTransition(
                            opacity: _textOpacityAnimation,
                            child: _buildText(),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Bottom spacer
                  const Expanded(flex: 1, child: SizedBox()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        AnimatedBuilder(
          animation: _logoController,
          builder: (context, child) {
            return Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            );
          },
        ),

        // Main logo container
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFD700), // Gold
                Color(0xFFFFA000), // Amber
                Color(0xFFFF8F00), // Orange
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.5),
                blurRadius: 30,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ZUBID text with enhanced styling
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Color(0xFFF5F5F5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: Text(
                    'ZUBID',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 3,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.7),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Enhanced auction icon
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.gavel,
                    color: Colors.white,
                    size: 18,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Rotating accent ring
        AnimatedBuilder(
          animation: _logoController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _logoController.value * 2 * 3.14159,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: CustomPaint(
                  painter: _AccentRingPainter(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Kurdish text
          Text(
            'بازاڕی بکە بەو نرخەی خۆت بە دڵتە',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.5,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(1, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // English subtitle
          Text(
            'Shop at the price you want',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Loading indicator
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccentRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

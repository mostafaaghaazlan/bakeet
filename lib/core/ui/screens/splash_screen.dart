import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bakeet/core/constant/app_colors/app_colors.dart';
import '../../constant/app_images/app_images.dart';
import '../../constant/app_size/app_size.dart';
import '../../utils/functions/location.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _backgroundRotationAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    _backgroundRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);

    _startAnimations();
    initializeApp();
  }

  void _startAnimations() async {
    _backgroundController.repeat();
    await _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _textController.forward();
  }

  void initializeApp() async {
    try {
      // Initialize location with timeout
      await GetLocation().getLocation().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          if (kDebugMode) {
            print("Location request timed out");
          }
          return;
        },
      );

      // Wait for animations to complete
      await Future.delayed(const Duration(milliseconds: 3000));

      // Navigate to login screen
      if (mounted) {
        _navigateToLogin();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error initializing: $e");
      }
      // Even if there's an error, navigate after delay
      await Future.delayed(const Duration(milliseconds: 3000));
      if (mounted) {
        _navigateToLogin();
      }
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/home');
    // If named routes are not set up, you can use:
    // Navigator.of(context).pushReplacement(
    //   MaterialPageRoute(builder: (context) => const LoginScreen()),
    // );
  }

  Widget _buildAnimatedBackground(Size size, bool isDark) {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.neutral900,
                      AppColors.neutral800.withValues(alpha: 0.9),
                      AppColors.primary.withValues(alpha: 0.1),
                    ]
                  : [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.neutral25,
                      AppColors.primary.withValues(alpha: 0.05),
                    ],
            ),
          ),
          child: Stack(
            children: [
              // Floating circles
              ...List.generate(3, (index) {
                final delay = index * 0.3;
                final rotation =
                    (_backgroundRotationAnimation.value + delay) * 2 * 3.14159;
                return Positioned(
                  left: size.width * 0.1 + (index * size.width * 0.3),
                  top: size.height * 0.2 + (index * size.height * 0.2),
                  child: Transform.rotate(
                    angle: rotation,
                    child: Container(
                      width: 80 + (index * 20),
                      height: 80 + (index * 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(
                          alpha: 0.1 - (index * 0.02),
                        ),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogoSection() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _backgroundController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: FadeTransition(
            opacity: _logoOpacityAnimation,
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Image.asset(
                logoPngImage,
                width: 120,
                height: 120,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppInfoSection(bool isDark) {
    return SlideTransition(
      position: _textSlideAnimation,
      child: FadeTransition(
        opacity: _textOpacityAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'app_name_english'.tr(),
              style: GoogleFonts.cairo(
                fontSize: AppSize.size_32,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.neutral800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'app_subtitle'.tr(),
              style: GoogleFonts.cairo(
                fontSize: AppSize.size_16,
                color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              height: 3,
              width: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary400],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSection(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            backgroundColor: isDark
                ? AppColors.neutral700
                : AppColors.neutral200,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'welcome_message'.tr(),
          style: GoogleFonts.cairo(
            fontSize: AppSize.size_14,
            color: isDark ? AppColors.neutral400 : AppColors.neutral600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
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
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.neutral900 : AppColors.neutral25,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            // Animated Background
            _buildAnimatedBackground(size, isDark),

            // Main Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo Section
                  _buildLogoSection(),

                  const SizedBox(height: 40),

                  // App Info Section
                  _buildAppInfoSection(isDark),

                  const SizedBox(height: 40),

                  // Loading Section
                  _buildLoadingSection(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

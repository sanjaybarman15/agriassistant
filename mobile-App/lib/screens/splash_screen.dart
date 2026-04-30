import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habitx/utils/theme_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward().then((_) async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        // final prefs = await SharedPreferences.getInstance();
        // final onboardingComplete =
        //     prefs.getBool('onboarding_complete') ?? false;
        // if (onboardingComplete) {
        //   context.go('/login');
        // } else {
        //   context.go('/onboarding');
        // }
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.primaryBlack,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: ThemeConstants.primaryYellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.track_changes,
                      size: 60,
                      color: ThemeConstants.primaryBlack,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Opacity(
                  opacity: _opacityAnimation.value,
                  child: Column(
                    children: [
                      Text(
                        'HabitX',
                        style: TextStyle(
                          color: ThemeConstants.primaryWhite,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track Habits & Share Stories',
                        style: TextStyle(
                          color: ThemeConstants.primaryYellow,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

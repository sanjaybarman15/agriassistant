import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habitx/screens/splash_screen.dart';
import 'package:habitx/screens/bottombar/bottom_nav_bar.dart';
import 'package:habitx/screens/settings_screen.dart';
import 'package:habitx/screens/authScreen/login.dart';
import 'package:habitx/screens/authScreen/signup.dart';
import 'package:habitx/screens/onboarding/onboarding.dart';

CustomTransitionPage<void> buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Right to left slide transition
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOutQuart;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => buildPageWithDefaultTransition(
        context: context,
        state: state,
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/signup',
      pageBuilder: (context, state) => buildPageWithDefaultTransition(
        context: context,
        state: state,
        child: const SignUpScreen(),
      ),
    ),
    GoRoute(
      path: '/main',
      pageBuilder: (context, state) => buildPageWithDefaultTransition(
        context: context,
        state: state,
        child: const BottomNavBar(),
      ),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => buildPageWithDefaultTransition(
        context: context,
        state: state,
        child: const SettingsScreen(),
      ),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => buildPageWithDefaultTransition(
        context: context,
        state: state,
        child: OnboardingScreen(),
      ),
    ),
  ],
);

import 'package:flutter/material.dart';
import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/theme_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String imageAsset;
  final Color textColor;
  final bool isLast;
  final VoidCallback? onDone;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.textColor,
    this.isLast = false,
    this.onDone,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(imageAsset, height: 230),
        const SizedBox(height: 32),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: textColor),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: textColor),
          ),
        ),
        if (isLast) ...[
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: textColor, // invert for button
              foregroundColor: (textColor == ThemeConstants.primaryBlack)
                  ? ThemeConstants.primaryWhite
                  : ThemeConstants.primaryBlack,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Done',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ],
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> pageData = [
    {
      'title': "Welcome to HabitX",
      'description': "Start your journey to better habits with us!",
      'imageAsset': 'assets/illustrations/onboarding2.svg',
    },
    {
      'title': "Track Your Progress",
      'description': "Easily monitor your daily habits and achievements.",
      'imageAsset': 'assets/illustrations/onboarding1.svg',
    },
    {
      'title': "Stay Motivated",
      'description': "Get reminders and stay on top of your goals!",
      'imageAsset': 'assets/illustrations/onboarding3.svg',
    },
  ];

  final List<Color> bgColors = [
    ThemeConstants.primaryYellow,
    ThemeConstants.backgroundPrimary,
    ThemeConstants.primaryYellow,
  ];

  final List<Color> textColors = [
    ThemeConstants.primaryBlack,
    ThemeConstants.primaryBlack,
    ThemeConstants.primaryBlack,
    // ThemeConstants.primaryWhite,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConcentricPageView(
        colors: bgColors,
        itemCount: pageData.length,
        itemBuilder: (int index) => OnboardingPage(
          title: pageData[index]['title']!,
          description: pageData[index]['description']!,
          imageAsset: pageData[index]['imageAsset']!,
          textColor: textColors[index],
          isLast: index == pageData.length - 1,
          onDone: index == pageData.length - 1
              ? () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('onboarding_complete', true);
                  context.go('/login');
                }
              : null,
        ),
        onFinish: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('onboarding_complete', true);
          context.go('/login');
        },
      ),
    );
  }
}

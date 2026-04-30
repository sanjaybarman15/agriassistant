import 'package:flutter/material.dart';
import 'package:habitx/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:habitx/utils/theme_constants.dart';
import 'dart:ui';

class TrophyAccordion extends StatefulWidget {
  final VoidCallback onClose;
  const TrophyAccordion({super.key, required this.onClose});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      pageBuilder: (context, animation1, animation2) => const SizedBox(),
      transitionBuilder: (context, animation1, animation2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 8.0 * animation1.value,
            sigmaY: 8.0 * animation1.value,
          ),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: TrophyAccordion(onClose: () => Navigator.of(context).pop()),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }

  @override
  State<TrophyAccordion> createState() => _TrophyAccordionState();
}

class _TrophyAccordionState extends State<TrophyAccordion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final points = userProvider.currentUser?.points ?? 0;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeConstants.backgroundPrimary.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ThemeConstants.primaryBlack.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Trophy Levels',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: ThemeConstants.primaryBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                      ),
                      IconButton(
                        onPressed: widget.onClose,
                        icon: const Icon(Icons.close),
                        color: ThemeConstants.primaryBlack.withOpacity(0.6),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildTrophyLevel(
                    context,
                    'Bronze',
                    '0-100 points',
                    [const Color(0xFFCD7F32), const Color(0xFFB87333), const Color(0xFF8B4513)],
                    points <= 100,
                  ),
                  _buildTrophyLevel(
                    context,
                    'Silver',
                    '101-300 points',
                    [const Color.fromARGB(255, 131, 128, 128), const Color(0xFF9E9E9E), const Color(0xFF707070)],
                    points > 100 && points <= 300,
                  ),
                  _buildTrophyLevel(
                    context,
                    'Gold',
                    '301-600 points',
                    [const Color(0xFFFFD700), const Color(0xFFFCC201), const Color(0xFFDAA520)],
                    points > 300 && points <= 600,
                  ),
                  _buildTrophyLevel(
                    context,
                    'Diamond',
                    '601-1000 points',
                    [const Color.fromARGB(255, 112, 209, 241), const Color(0xFF59D8FF), const Color.fromARGB(255, 0, 101, 142)],
                    points > 600 && points <= 1000,
                  ),
                  _buildTrophyLevel(
                    context,
                    'Titanium',
                    '1001-2000 points',
                    [const Color(0xFFBEC2CB), const Color(0xFF808080), const Color(0xFF4A4A4A)],
                    points > 1000 && points <= 2000,
                  ),
                  _buildTrophyLevel(
                    context,
                    'Legend',
                    '2000+ points',
                    [const Color.fromARGB(255, 255, 0, 230), Colors.purple, Colors.blue],
                    points > 2000,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrophyLevel(
    BuildContext context,
    String level,
    String points,
    List<Color> colors,
    bool isCurrent, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isCurrent ? colors[0].withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isCurrent ? Border.all(color: colors[0], width: 2) : null,
          ),
          child: Row(
            children: [
              Icon(Icons.emoji_events, color: colors[0], size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(level, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(points, style: TextStyle(color: Colors.black.withOpacity(0.6))),
                  ],
                ),
              ),
              if (isCurrent) const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
        ),
        if (!isLast) const SizedBox(height: 16),
      ],
    );
  }
}

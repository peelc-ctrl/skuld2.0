import 'package:flutter/material.dart';

class AnimatedStreakCard extends StatefulWidget {
  final int streakCount;
  final int longestStreak;  // Adding longest streak to the widget

  const AnimatedStreakCard({super.key, required this.streakCount, required this.longestStreak});

  @override
  _AnimatedStreakCardState createState() => _AnimatedStreakCardState();
}

class _AnimatedStreakCardState extends State<AnimatedStreakCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 12.0, end: 28.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward(); // Start entrance animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If current streak is 0, graying out the card
    bool isStreakBroken = widget.streakCount == 0;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: 300, // Controlled width
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: isStreakBroken
                ? const LinearGradient(
                    colors: [Color(0xFFB0BEC5), Color(0xFF90A4AE)], // Gray gradient for broken streak
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFF4A148C), Color(0xFF880E4F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isStreakBroken
                              ? Colors.grey.withOpacity(0.6)
                              : Colors.orange.withOpacity(0.6),
                          blurRadius: _glowAnimation.value,
                          spreadRadius: 2,
                        ),
                      ],
                      color: isStreakBroken
                          ? Colors.grey.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                    ),
                    child: Icon(
                      Icons.local_fire_department,
                      color: isStreakBroken
                          ? Colors.grey
                          : Colors.orangeAccent,
                      size: 27,
                    ),
                  );
                },
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isStreakBroken
                        ? '🔥 Streak Broken!'
                        : '🔥 Streak Alive!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isStreakBroken
                        ? 'Start your streak today!'
                        : '${widget.streakCount} days strong!',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

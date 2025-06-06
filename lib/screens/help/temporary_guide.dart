import 'package:flutter/material.dart';
import 'package:gym_buddy_app/config.dart';
import 'package:gym_buddy_app/screens/help/app_help_content.dart';

class TemporaryGuide extends StatefulWidget {
  const TemporaryGuide({super.key});

  @override
  State<TemporaryGuide> createState() => _TemporaryGuideState();
}

class _TemporaryGuideState extends State<TemporaryGuide> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  bool _isVisible = true;
  @override
  void initState() {
    super.initState();
    
    // Set up the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    // Define the opacity animation
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut)
    );
    
    // Register the callback for when all steps are completed
    AppHelpContent.setOnAllStepsCompletedCallback(_hide);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _hide() {
    // Mark guide as seen in config
    Config.setHasSeenGuide(true);
    
    // Start the hide animation
    setState(() {
      _isVisible = false;
    });
    
    _animationController.forward();
  }
  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'how to use the app',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _hide,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 20,
                ),
              ],
            ),            const SizedBox(height: 10),
            AppHelpContent.getHelpContent(context),
          ],
        ),
      ),
    );
  }
}

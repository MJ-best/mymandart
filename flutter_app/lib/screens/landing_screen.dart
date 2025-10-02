import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Material;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Mandalart Journey'),
        backgroundColor: CupertinoColors.systemBackground,
        border: null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Hero animation tag for smooth transition
              Hero(
                tag: 'app-title',
                child: Material(
                  color: CupertinoColors.transparent,
                  child: const Text(
                    'What is a Mandalart?',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.5,
                      color: CupertinoColors.label,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'A Mandalart is a 3x3 grid of squares, with the main goal in the center square. The surrounding eight squares contain related sub-goals.\n\nEach of these sub-goals then becomes the center of its own 3x3 grid, where you can add more detailed actions or ideas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: CupertinoColors.secondaryLabel,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 44),
              // Add haptic feedback and accessibility
              Semantics(
                label: 'Start creating your Mandalart',
                button: true,
                child: CupertinoButton.filled(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    GoRouter.of(context).go('/create');
                  },
                  child: const Text('Start Your Journey'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

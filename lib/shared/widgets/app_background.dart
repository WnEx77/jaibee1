import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                isDarkMode
                    ? 'assets/images/background3.png' // dark mode
                    : 'assets/images/background6.png', // light mode
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Foreground content
        child,
      ],
    );
  }
}

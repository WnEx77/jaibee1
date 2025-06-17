import 'package:flutter/material.dart';

class AnimatedScreenWrapper extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset beginOffset;

  const AnimatedScreenWrapper({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.beginOffset = const Offset(0, 0.1),
  });

  @override
  State<AnimatedScreenWrapper> createState() => _AnimatedScreenWrapperState();
}

class _AnimatedScreenWrapperState extends State<AnimatedScreenWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _slideAnimation = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

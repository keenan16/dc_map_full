import 'package:flutter/material.dart';

class AnimatedDropPin extends StatefulWidget {
  const AnimatedDropPin({super.key});

  @override
  State<AnimatedDropPin> createState() => AnimatedDropPinState();
}

class AnimatedDropPinState extends State<AnimatedDropPin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _offsetAnim = Tween<double>(begin: -60, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.bounceOut),
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
    return AnimatedBuilder(
      animation: _offsetAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _offsetAnim.value),
          child: child,
        );
      },
      child: const Icon(Icons.location_pin, size: 30, color: Colors.red),
    );
  }
}

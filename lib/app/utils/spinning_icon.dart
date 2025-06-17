import 'package:flutter/material.dart';

class SpinningIcon extends AnimatedWidget {
  const SpinningIcon({
    super.key,
    required this.controller,
    required this.icon,
    required this.onPressed,
  }) : super(listenable: controller);

  final VoidCallback onPressed;
  final Icon icon;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.linear,
    );

    return RotationTransition(
      turns: animation,
      child: IconButton(icon: icon, onPressed: onPressed),
    );
  }
}

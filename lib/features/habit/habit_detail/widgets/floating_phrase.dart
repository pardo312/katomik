import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloatingPhrase extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final Offset startPosition;
  final Offset endPosition;

  const FloatingPhrase({
    super.key,
    required this.animation,
    required this.child,
    required this.startPosition,
    required this.endPosition,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = animation.value;
        final x =
            startPosition.dx +
            (endPosition.dx - startPosition.dx) * math.sin(value * 2 * math.pi);
        final y =
            startPosition.dy +
            (endPosition.dy - startPosition.dy) * math.cos(value * 2 * math.pi);

        return Positioned(
          left: x * MediaQuery.of(context).size.width * 0.8,
          top: y * 400,
          child: Transform.scale(
            scale: 0.9 + 0.1 * math.sin(value * 4 * math.pi),
            child: this.child,
          ),
        );
      },
    );
  }
}
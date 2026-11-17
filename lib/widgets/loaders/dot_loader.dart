import 'package:flutter/material.dart';

class DotLoader extends StatefulWidget {
  const DotLoader({super.key});

  @override
  State<DotLoader> createState() => _DotLoaderState();
}

class _DotLoaderState extends State<DotLoader>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double getDotPosition(int index) {

    double animationValue = _controller.value;

    double delay = index * 0.2;

    double value = animationValue - delay;

    if (value < 0) {
      value += 1;
    }

    if (value >= 0 && value <= 0.2) {

      return -12 * (value / 0.2);

    } else if (value > 0.2 && value <= 0.4) {

      return -12 * (1 - ((value - 0.2) / 0.2));
    }

    return 0;
  }

  Widget buildDot(int index) {

    return AnimatedBuilder(
      animation: _controller,

      builder: (context, child) {

        return Transform.translate(
          offset: Offset(0, getDotPosition(index)),

          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),

            width: 10,
            height: 10,

            decoration: const BoxDecoration(
              color: Colors.deepPurpleAccent,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildDot(0),
        buildDot(1),
        buildDot(2),
      ],
    );
  }
}
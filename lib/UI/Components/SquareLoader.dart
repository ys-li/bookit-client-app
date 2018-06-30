import 'package:flutter/material.dart';
import 'dart:math' as math;

class PulsateCurve extends Curve {
  @override
  double transform(double t) {
    if (t == 0 || t == 1)
      return 0.1;
    return math.sin(t * math.PI) * 0.65 + 0.35;
  }
}

class _AnimatedLoader extends AnimatedWidget {
  static final _opacityTween = new CurveTween(curve: new PulsateCurve());

  _AnimatedLoader({
    Key key,
    this.alignment: FractionalOffset.center,
    Animation<double> animation,
    this.child,
  }) : super(key: key, listenable: animation);

  final FractionalOffset alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    final Matrix4 transform = new Matrix4.rotationZ(animation.value * math.PI * 2.0);
    return new Transform(
        alignment: alignment,
        transform: transform,
        child: new Opacity(
          opacity: _opacityTween.evaluate(animation),
          child: child,
        )
    );
  }
}


class SquareLoader extends StatefulWidget {
  final bool white;
  SquareLoader({bool white = false}) : this.white = white;
  SquareLoaderState createState() => new SquareLoaderState();
}

class SquareLoaderState extends State<SquareLoader> with TickerProviderStateMixin {
  AnimationController _controller;

  @override initState() {
    super.initState();
    _controller = new AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return new _AnimatedLoader(
        animation: _controller,
        alignment: FractionalOffset.center,
        child: new Container(
          margin: const EdgeInsets.all(10.0),
          color: widget.white ? const Color(0xFFEEEEEE) : const Color(0xFF03A9F4),
          height: 28.0,
          width: 28.0,
        ),
      );
  }

  @override dispose(){
    _controller.dispose();
    super.dispose();
  }
}

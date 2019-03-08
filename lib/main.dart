import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:quiver/iterables.dart';
import 'package:quiver/time.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AnimGraphr(),
    );
  }
}

class AnimGraphr extends StatefulWidget {
  @override
  _AnimGraphrState createState() => _AnimGraphrState();
}

class NamedCurve {
  final String name;
  final Curve curve;

  const NamedCurve(this.name, this.curve);
}

class _AnimGraphrState extends State<AnimGraphr>
    with SingleTickerProviderStateMixin {
  final curves = [
    const NamedCurve('bounceIn', Curves.bounceIn),
    const NamedCurve('bounceInOut', Curves.bounceInOut),
    const NamedCurve('bounceOut', Curves.bounceOut),
    const NamedCurve('ease', Curves.ease),
    const NamedCurve('easeIn', Curves.easeIn),
    const NamedCurve('easeInBack', Curves.easeInBack),
    const NamedCurve('easeInCirc', Curves.easeInCirc),
    const NamedCurve('easeInExpo', Curves.easeInExpo),
    const NamedCurve('easeInCubic', Curves.easeInCubic),
    const NamedCurve('easeInQuad', Curves.easeInQuad),
    const NamedCurve('easeInQuart', Curves.easeInQuart),
    const NamedCurve('easeInQuint', Curves.easeInQuint),
    const NamedCurve('easeInSine', Curves.easeInSine),
    const NamedCurve('easeInOut', Curves.easeInOut),
    const NamedCurve('easeInToLinear', Curves.easeInToLinear),
    const NamedCurve('easeOut', Curves.easeOut),
    const NamedCurve('easeOutBack', Curves.easeOutBack),
    const NamedCurve('easeOutCirc', Curves.easeOutCirc),
    const NamedCurve('easeOutExpo', Curves.easeOutExpo),
    const NamedCurve('easeOutCubic', Curves.easeOutCubic),
    const NamedCurve('easeOutQuad', Curves.easeOutQuad),
    const NamedCurve('easeOutQuart', Curves.easeOutQuart),
    const NamedCurve('easeOutQuint', Curves.easeOutQuint),
    const NamedCurve('easeOutSine', Curves.easeOutSine),
  ];

  Curve currentCurve = Curves.bounceIn;

  AnimationController controller;
  CurvedAnimation anim;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: aSecond, vsync: this)
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed)
          Future.delayed(aSecond, () => controller.reverse());
      });
  }

  @override
  Widget build(BuildContext context) {
    anim = CurvedAnimation(parent: controller, curve: currentCurve);

    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            DropdownButton(
              value: currentCurve,
              items: curves.map(_buildCurveMenuItem).toList(),
              onChanged: onCurveChanged,
            ),
            Container(
              color: Colors.grey.shade200,
              padding: const EdgeInsets.all(12),
              constraints: BoxConstraints.expand(height: 200),
              child: CustomPaint(painter: CurvePainter(controller, anim)),
            ),
            ConstrainedBox(
              constraints: BoxConstraints.expand(height: 200),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: anim.value * 200,
                      child: Opacity(
                        opacity: min([1, anim.value + .2]),
                        child: Container(
                            color: Colors.cyan,
                            height: 100,
                            width: 20 + (anim.value * 100)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            RaisedButton(onPressed: controller.forward, child: Text('Animate'))
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<Curve> _buildCurveMenuItem(NamedCurve c) => DropdownMenuItem(
        child: Text('${c.name}'),
        value: c.curve,
      );

  void onCurveChanged(Curve c) => setState(() => currentCurve = c);
}

final axisPaint = Paint()
  ..color = Colors.grey.shade600
  ..strokeWidth = 2;

const divisions = 200;

class CurvePainter extends CustomPainter {
  final CurvedAnimation anim;
  final AnimationController controller;

  CurvePainter(this.controller, this.anim);

  @override
  void paint(Canvas canvas, Size size) {
    final points = computeCurveValues(anim, divisions);
    print('points $size $points');

    canvas.drawLine(
        Offset(0, size.height), Offset(size.width, size.height), axisPaint);
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), axisPaint);

    final ptPaint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 2;
    canvas.drawPoints(
        PointMode.polygon,
        enumerate(points)
            .map((y) => Offset(
                  y.index / divisions * size.width,
                  y.value * size.height,
                ))
            .toList(),
        ptPaint);

    canvas.drawCircle(
        Offset(controller.value * size.width,
            points[(controller.value * (divisions - 1)).floor()] * size.height),
        5.0,
        Paint()..color = Colors.pink);
  }

  @override
  bool shouldRepaint(CurvePainter oldDelegate) {
    return controller.value != oldDelegate.controller.value;
  }
}

List<double> computeCurveValues(CurvedAnimation anim, int divisions) {
  return List.generate(
      divisions, (index) => 1 - anim.curve.transform(index / divisions));
}

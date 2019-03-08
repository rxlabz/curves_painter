import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

class _AnimGraphrState extends State<AnimGraphr>
    with SingleTickerProviderStateMixin {
  final curves = [
    Curves.bounceIn,
    Curves.bounceInOut,
    Curves.bounceOut,
    Curves.ease,
    Curves.easeIn,
    Curves.easeInBack,
    Curves.easeInCirc,
    Curves.easeInExpo,
    Curves.easeInCubic,
    Curves.easeInQuad,
    Curves.easeInQuart,
    Curves.easeInQuint,
    Curves.easeInSine,
    Curves.easeInOut,
    Curves.easeInToLinear,
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
              constraints: BoxConstraints.expand(height: 200),
              child: CustomPaint(
                painter: CurvePainter(currentCurve, this, controller),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints.expand(height: 200),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: anim.value * 200,
                    child: Container(
                      color: Colors.cyan,
                      height: 100,
                      width: 100,
                    ),
                  )
                ],
              ),
            ),
            RaisedButton(
              onPressed: controller.forward,
              child: Text('Animate'),
            )
          ],
        ),
      ),
    ); /**/
  }

  DropdownMenuItem<Curve> _buildCurveMenuItem(Curve c) => DropdownMenuItem(
        child: Text('$c'),
        value: c,
      );

  void onCurveChanged(Curve c) {
    setState(() => currentCurve = c);
  }
}

class CurvePainter extends CustomPainter {
  final Curve curve;
  final TickerProvider ticker;
  final AnimationController controller;

  CurvePainter(this.curve, this.ticker, this.controller);

  @override
  void paint(Canvas canvas, Size size) {
    final points = computeCurveValues(controller, curve, 200);
    print('points $size $points');

    canvas.drawRect(
        Rect.fromPoints(Offset.zero, Offset(size.width, size.height)),
        Paint()..color = Colors.grey.shade200);

    final ptPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;
    //points.forEach((p){
    canvas.drawPoints(
        PointMode.polygon,
        enumerate(points)
            .map((y) => Offset(
                  y.index / 200 * size.width,
                  y.value * size.height,
                ))
            .toList(),
        ptPaint);
    //});
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

List<double> computeCurveValues(AnimationController parent, Curve curve,
    [int divisions = 10]) {
  List<double> points = <double>[];
  final anim = CurvedAnimation(parent: parent, curve: curve);
  return List.generate(
      divisions, (index) => 1 - anim.curve.transform(index / divisions));
  /*anim.addListener(() {
    print('value ${anim.value}');
    points.add(anim.value);
  });*/
  parent.forward();
  return points;
}

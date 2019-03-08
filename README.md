# Flutter curves

Flutter animation [curves]() visualizer based on a [CustomPainter]()

![curves](curves.gif)

```dart

class CurvePainter extends CustomPainter {
  final CurvedAnimation anim;
  final AnimationController controller;

  CurvePainter(this.controller, this.anim);

  @override
  void paint(Canvas canvas, Size size) {
    final points = computeCurveValues(anim, divisions);

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
      ptPaint,
    );

    canvas.drawCircle(
      Offset(controller.value * size.width,
          points[(controller.value * (divisions - 1)).floor()] * size.height),
      5.0,
      Paint()..color = Colors.pink,
    );
  }

  @override
  bool shouldRepaint(CurvePainter oldDelegate) =>
      controller.value != oldDelegate.controller.value;
}

List<double> computeCurveValues(CurvedAnimation anim, int divisions) =>
    List.generate(
        divisions, (index) => 1 - anim.curve.transform(index / divisions));


```
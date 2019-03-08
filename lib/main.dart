import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:quiver/iterables.dart';
import 'package:quiver/time.dart';

import 'data.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(home: AnimGraphr());
}

class AnimGraphr extends StatefulWidget {
  @override
  _AnimGraphrState createState() => _AnimGraphrState();
}

class _AnimGraphrState extends State<AnimGraphr>
    with SingleTickerProviderStateMixin {
  Curve currentCurve = Curves.bounceIn;

  AnimationController controller;

  CurvedAnimation anim;

  int duration = 1000;

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
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller.duration = aMillisecond * duration;
    anim = CurvedAnimation(parent: controller, curve: currentCurve);

    bool running = controller.status != AnimationStatus.dismissed;

    return Scaffold(
      appBar: AppBar(title: Text('Curves')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: running ? Colors.grey : Colors.cyan,
        child: Icon(Icons.play_arrow),
        onPressed: running ? null : controller.forward,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            DropdownButton(
              value: currentCurve,
              items: curves.map(_buildCurveMenuItem).toList(),
              onChanged: _onCurveChanged,
            ),
            _buildDurationControl(),
            Container(
              color: Colors.grey.shade200,
              padding: const EdgeInsets.all(12),
              constraints: BoxConstraints.expand(height: 200),
              child: CustomPaint(
                  key: Key('curveGraph'),
                  painter: CurvePainter(controller, anim)),
            ),
            AnimatedExample(value: anim.value),
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<Curve> _buildCurveMenuItem(NamedCurve c) => DropdownMenuItem(
        child: Text('${c.name}'),
        value: c.curve,
      );

  void _onCurveChanged(Curve c) => setState(() => currentCurve = c);

  Widget _buildDurationControl() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Duration',
            style: TextStyle(color: Colors.grey),
          ),
          _buildIconButton(),
          Text('$duration ms'),
          IconButton(
            color: Colors.blueGrey,
            icon: Icon(Icons.add),
            onPressed:
                duration < 5000 ? () => setState(() => duration += 100) : null,
          ),
        ],
      );

  IconButton _buildIconButton() => IconButton(
        color: Colors.blueGrey,
        icon: Icon(Icons.remove),
        onPressed:
            duration > 100 ? () => setState(() => duration -= 100) : null,
      );
}

class AnimatedExample extends StatelessWidget {
  final double value;

  const AnimatedExample({Key key, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemWidth = 20 + (value * 100);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints.expand(height: 200),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: value * (constraints.maxWidth - itemWidth - 16),
                  child: Opacity(
                    opacity: min([1, value + .2]),
                    child: Container(
                        color: Colors.cyan, height: 100, width: itemWidth),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class CurvePainter extends CustomPainter {
  CurvePainter(this.controller, this.anim);

  final CurvedAnimation anim;

  final AnimationController controller;

  @override
  void paint(Canvas canvas, Size size) {
    final points = generateCurveValues(anim, divisions);
    _drawAxis(canvas, size);
    _drawCurve(canvas, points, size);
    _drawCurrentValueMarker(canvas, size, points);
  }

  void _drawCurrentValueMarker(Canvas canvas, Size size, List<double> points) {
    canvas.drawCircle(
      Offset(controller.value * size.width,
          points[(controller.value * (divisions - 1)).floor()] * size.height),
      5.0,
      Paint()..color = Colors.pink,
    );
  }

  void _drawCurve(Canvas canvas, List<double> points, Size size) {
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
  }

  void _drawAxis(Canvas canvas, Size size) {
    _paintText(canvas, 'time', Offset(size.width, size.height) - Offset(30, 18),
        size.width);
    _paintText(canvas, 'value', Offset(10, 0), size.width);

    canvas.drawLine(
        Offset(0, size.height), Offset(size.width, size.height), axisPaint);
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), axisPaint);
  }

  TextPainter _paintText(
          Canvas canvas, String text, Offset offset, double width) =>
      TextPainter(
          text: TextSpan(text: text, style: TextStyle(color: Colors.black)),
          textDirection: TextDirection.ltr)
        ..layout(maxWidth: width)
        ..paint(canvas, offset);

  @override
  bool shouldRepaint(CurvePainter oldDelegate) =>
      controller.value != oldDelegate.controller.value;
}

List<double> generateCurveValues(CurvedAnimation anim, int divisions) =>
    List.generate(
        divisions, (index) => 1 - anim.curve.transform(index / divisions));

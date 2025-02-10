import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DrawingApp(),
    );
  }
}

enum DrawMode { line, square, circle, arc, emoji }

class DrawingApp extends StatefulWidget {
  @override
  _DrawingAppState createState() => _DrawingAppState();
}

class _DrawingAppState extends State<DrawingApp> {
  List<List<Offset>> lines = [];
  DrawMode _selectedMode = DrawMode.line;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drawing App'),
        actions: [
          DropdownButton<DrawMode>(
            value: _selectedMode,
            onChanged: (DrawMode? newMode) {
              if (newMode != null) {
                setState(() {
                  _selectedMode = newMode;
                });
              }
            },
            items: DrawMode.values.map((DrawMode mode) {
              return DropdownMenuItem(
                value: mode,
                child: Text(mode.toString().split('.').last),
              );
            }).toList(),
          ),
        ],
      ),
      body: GestureDetector(
        onPanStart: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            final localPosition = renderBox.globalToLocal(details.globalPosition);
            if (_selectedMode == DrawMode.line) {
              lines.add([localPosition]);
            } else {
              lines.add([localPosition, localPosition]);
            }
          });
        },
        onPanUpdate: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            final localPosition = renderBox.globalToLocal(details.globalPosition);
            if (_selectedMode == DrawMode.line) {
              lines.last.add(localPosition);
            } else {
              lines.last[1] = localPosition;
            }
          });
        },
        child: CustomPaint(
          painter: MyPainter(lines, _selectedMode),
          size: Size.infinite,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            lines.clear();
          });
        },
        child: Icon(Icons.clear),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final List<List<Offset>> lines;
  final DrawMode mode;

  MyPainter(this.lines, this.mode);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (final line in lines) {
      if (line.length < 2) continue;

      Offset start = line[0];
      Offset end = line[1];

      switch (mode) {
        case DrawMode.line:
          for (int i = 0; i < line.length - 1; i++) {
            canvas.drawLine(line[i], line[i + 1], paint);
          }
          break;
        case DrawMode.square:
          canvas.drawRect(Rect.fromPoints(start, end), paint);
          break;
        case DrawMode.circle:
          double radius = (end - start).distance / 2;
          Offset center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
          canvas.drawCircle(center, radius, paint);
          break;
        case DrawMode.arc:
          Rect rect = Rect.fromPoints(start, end);
          canvas.drawArc(rect, 0, 3.14, false, paint);
          break;
        case DrawMode.emoji:
          _drawEmoji(canvas, start, end);
          break;
      }
    }
  }

  void _drawEmoji(Canvas canvas, Offset start, Offset end) {
    Paint facePaint = Paint()..color = Colors.yellow;
    Paint eyePaint = Paint()..color = Colors.black;
    Paint mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    double radius = (end - start).distance / 2;
    Offset center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);

    canvas.drawCircle(center, radius, facePaint);
    canvas.drawCircle(center.translate(-radius / 3, -radius / 3), radius / 6, eyePaint);
    canvas.drawCircle(center.translate(radius / 3, -radius / 3), radius / 6, eyePaint);

    Rect mouthRect = Rect.fromCenter(center: center.translate(0, radius / 4), width: radius, height: radius / 2);
    canvas.drawArc(mouthRect, 0, 3.14, false, mouthPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

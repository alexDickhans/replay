import 'dart:math';

import 'package:flutter/material.dart';
import 'dataStructure/position.dart';

const double fieldWidth = 3.676414;

class PathDrawer extends CustomPainter {
  List<List<Position>> robots;

  PathDrawer(this.robots);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Go through the robot positions painting each list of positions with a different color, represent robots as circles
    for (var i = 0; i < robots.length; i++) {
      if (i % 10 == 0) {
        paint.color = Colors.blue;
      } else if (i % 10 == 1) {
        paint.color = Colors.red;
      } else if (i % 10 == 2) {
        paint.color = Colors.green;
      } else if (i % 10 == 3) {
        paint.color = Colors.yellow;
      } else if (i % 10 == 4) {
        paint.color = Colors.purple;
      } else if (i % 10 == 5) {
        paint.color = Colors.orange;
      } else if (i % 10 == 6) {
        paint.color = Colors.pink;
      } else if (i % 10 == 7) {
        paint.color = Colors.teal;
      } else if (i % 10 == 8) {
        paint.color = Colors.brown;
      } else {
        paint.color = Colors.cyan;
      }

      for (var j = 0; j < robots[i].length; j++) {
        canvas.drawCircle(
          Offset(robots[i][j].getXScreen(size.width, fieldWidth),
              robots[i][j].getYScreen(size.height, fieldWidth)),
          1.5,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

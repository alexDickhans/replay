import 'dart:math';

import 'package:flutter/material.dart';
import 'package:replay/utils.dart';
import 'dataStructure/position.dart';

const double fieldWidth = 3.676414;

class PathDrawer extends CustomPainter {
  List<List<Position>> robots;
  List<List<Position>> paths;

  PathDrawer(this.robots, this.paths);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Go through the robot positions painting each list of positions with a different color, represent robots as circles
    for (var i = 0; i < robots.length; i++) {
      paint.color = getColor(i);

      for (var j = 0; j < robots[i].length; j++) {
        canvas.drawCircle(
          Offset(robots[i][j].getXScreen(size.width, fieldWidth),
              robots[i][j].getYScreen(size.height, fieldWidth)),
          1.5,
          paint,
        );
      }

      // Draw the path of the robot
      for (var j = 0; j < paths[i].length - 1; j++) {
        canvas.drawLine(
          Offset(paths[i][j].getXScreen(size.width, fieldWidth),
              paths[i][j].getYScreen(size.height, fieldWidth)),
          Offset(paths[i][j + 1].getXScreen(size.width, fieldWidth),
              paths[i][j + 1].getYScreen(size.height, fieldWidth)),
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

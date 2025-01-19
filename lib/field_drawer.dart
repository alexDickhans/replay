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

        const double robotSizeMeters = 0.1778*2;
        final double robotSizePixels =
            robotSizeMeters / fieldWidth * size.width;

        if (robots[i][j].t != null) {
          final double theta = -robots[i][j].t!;
          final double halfSize = robotSizePixels / 2;

          final Offset center = Offset(
            robots[i][j].getXScreen(size.width, fieldWidth),
            robots[i][j].getYScreen(size.height, fieldWidth),
          );

          final List<Offset> corners = [
            Offset(-halfSize, -halfSize),
            Offset(halfSize, -halfSize),
            Offset(halfSize, halfSize),
            Offset(-halfSize, halfSize),
          ];

          final List<Offset> rotatedCorners = corners.map((corner) {
            final double x = corner.dx * cos(theta) - corner.dy * sin(theta);
            final double y = corner.dx * sin(theta) + corner.dy * cos(theta);
            return center + Offset(x, y);
          }).toList();

          for (int k = 0; k < rotatedCorners.length; k++) {
            canvas.drawLine(
              rotatedCorners[k],
              rotatedCorners[(k + 1) % rotatedCorners.length],
              paint,
            );
          }
        }
      }

      // Draw the path of the robot
      for (var j = 0; j < paths[i].length - 1; j++) {
        // Only draw the line if the robot has moved more than 0.1 meters
        if (sqrt(pow(paths[i][j].x - paths[i][j + 1].x, 2) +
                pow(paths[i][j].y - paths[i][j + 1].y, 2)) >
            0.4) {
          continue;
        }
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

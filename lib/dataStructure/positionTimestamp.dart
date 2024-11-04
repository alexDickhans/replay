import 'dart:convert';
import 'position.dart';

class PositionTimestamp {
  final double time;
  final List<Position> positions;

  PositionTimestamp({required this.time, required this.positions});

  factory PositionTimestamp.fromJson(Map<String, dynamic> json) {
    double timeValue;
    if (json['time'] is int) {
      timeValue = (json['time'] as int).toDouble();
    } else {
      timeValue = json['time'];
    }

    return PositionTimestamp(
      time: timeValue,
      positions: List<Position>.from(json['data'].map((x) => Position.fromJson(x))),
    );
  }
}

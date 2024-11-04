import 'dart:convert';
import 'position.dart';

class PositionTimestamp {
  final double time;
  final List<Position> positions;

  PositionTimestamp({required this.time, required this.positions});

  factory PositionTimestamp.fromJson(Map<String, dynamic> json) {
    return PositionTimestamp(
      time: json['time'],
      positions: List<Position>.from(json['data'].map((x) => Position.fromJson(x))),
    );
  }
}

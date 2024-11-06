// File to load a list of positions from json

import 'dart:convert';
import 'position.dart';
import 'positionTimestamp.dart';

class PositionList {
  final List<PositionTimestamp> positionList;
  final String filename;

  PositionList({required this.positionList, this.filename = ''});

  factory PositionList.fromJson(Map<String, dynamic> json, String filename) {
    return PositionList(
      positionList: List<PositionTimestamp>.from(json['data'].map((x) => PositionTimestamp.fromJson(x))),
      filename: filename,
    );
  }

  List<Position> getPositions(double time) {
    // if there are no items in the list, return an empty list
    if (positionList.isEmpty) {
      return [];
    }

    for (var i = 1; i < positionList.length; i++) {
      if (positionList[i].time > time) {
        return positionList[i-1].positions;
      }
    }

    // Return final item
    return positionList[positionList.length-1].positions;
  }

  double minTime() {
    if (positionList.isEmpty) {
      return 0.0;
    }

    return positionList[0].time;
  }

  double maxTime() {
    if (positionList.isEmpty) {
      return 0.0;
    }

    return positionList[positionList.length-1].time;
  }
}
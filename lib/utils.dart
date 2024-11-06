

import 'dart:ui';

import 'package:flutter/material.dart';

MaterialColor getColor(int i) {
  if (i % 10 == 0) {
    return Colors.blue;
  } else if (i % 10 == 1) {
    return Colors.red;
  } else if (i % 10 == 2) {
    return Colors.green;
  } else if (i % 10 == 3) {
    return Colors.yellow;
  } else if (i % 10 == 4) {
    return Colors.purple;
  } else if (i % 10 == 5) {
    return Colors.orange;
  } else if (i % 10 == 6) {
    return Colors.pink;
  } else if (i % 10 == 7) {
    return Colors.teal;
  } else if (i % 10 == 8) {
    return Colors.brown;
  }
  return Colors.cyan;
}
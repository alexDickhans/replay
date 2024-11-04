class Position {
  final double x;
  final double y;
  final double? t;

  Position({required this.x, required this.y, this.t});

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      x: json['x'],
      y: json['y'],
      t: json['t'],
    );
  }

  double getXScreen(double screenWidth, double fieldWidth) {
    return (-x / fieldWidth + 0.5) * screenWidth;
  }

  double getYScreen(double screenHeight, double fieldWidth) {
    return (-y / fieldWidth + 0.5) * screenHeight;
  }

  // tostring
  @override
  String toString() {
    return "x: $x, y: $y";
  }
}
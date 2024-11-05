class Position {
  final double x;
  final double y;
  final double? t;

  Position({required this.x, required this.y, this.t});

  factory Position.fromJson(Map<String, dynamic> json) {
    double x;
    if (json['x'] is int) {
      x = (json['x'] as int).toDouble();
    } else {
      x = json['x'];
    }

    double y;
    if (json['y'] is int) {
      y = (json['y'] as int).toDouble();
    } else {
      y = json['y'];
    }

    double? t;
    if (json['t'] is int) {
      t = (json['t'] as int).toDouble();
    } else if (json['t'] is double){
      t = json['t'];
    } else {
      t = null;
    }

    return Position(
      x: x,
      y: y,
      t: t,
    );
  }

  double getXScreen(double screenWidth, double fieldWidth) {
    return (-x / fieldWidth + 0.5) * screenWidth;
  }

  double getYScreen(double screenHeight, double fieldWidth) {
    return (y / fieldWidth + 0.5) * screenHeight;
  }

  // tostring
  @override
  String toString() {
    return "x: $x, y: $y";
  }
}
import 'dart:math';
import 'dart:ui' as ui;

class Label {
  final String id;
  final String name;
  final double probability;

  const Label(this.id, this.name, this.probability);

  factory Label.fromJson(Map<String, dynamic> json) {
    return Label(json["id"], json["name"], json["probability"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "probability": probability
    };
  }
}

class Shape {
  const Shape();

  factory Shape.fromJson(Map<String, dynamic> json) {
    if (json["type"] == "RECTANGLE") {
      return Rectangle.fromJson(json);
    }
    if (json["type"] == "POLYGON") {
      return Polygon.fromJson(json);
    }
    if (json["type"] == "ROTATED_RECTANGLE") {
      return RotatedRectangle.fromJson(json);
    }
    print(json);
    throw "unimplemented shapetype";
  }

  Map<String, dynamic> toMap() {
    throw "override missing";
  }

  Rectangle get rectangle {
    throw "unimplemented";
  }
}

class Polygon extends Shape {
  List<ui.Offset> points;
  @override final Rectangle rectangle;

  Polygon(this.points, this.rectangle);

  factory Polygon.fromJson(Map<String, dynamic> json) {
    return Polygon(
      List<ui.Offset>.from(json["points"].map((p) => ui.Offset(p["x"].toDouble(), p["y"].toDouble()))),
      Rectangle.fromJson(json["rect"])
    );
  }

  @override Map<String, dynamic> toMap() {
    return {
      "type": "POLYGON",
      "points": points.map((p) => {"x": p.dx, "y": p.dy}).toList(),
      "rect": rectangle.toMap()
    };
  }

}

class RotatedRectangle extends Shape {
  final double centerX;
  final double centerY;
  final double width;
  final double height;
  final double angle;

  const RotatedRectangle(this.centerX, this.centerY, this.width, this.height, this.angle);

  ui.Rect toRect() {
    return ui.Rect.fromCenter(center: ui.Offset(centerX, centerY), width: width, height: height);
  }

  factory RotatedRectangle.fromJson(Map<String, dynamic> json) {
    return RotatedRectangle(
      json["x"].toDouble(),
      json["y"].toDouble(),
      json["width"].toDouble(),
      json["height"].toDouble(),
      json["angle"].toDouble()
    );
  }

  @override Map<String, dynamic> toMap() {
    return {
      "type": "ROTATED_RECTANGLE",
      "x": centerX,
      "y": centerY,
      "width": width,
      "height": height,
      "angle": angle
    };
  }

  double get angleInRadians {
    return angle / 360.0 * 2 * pi;
  }
}

class Rectangle extends Shape {
  double x;
  double y;
  double width;
  double height;

  Rectangle(this.x, this.y, this.width, this.height);

  ui.Rect toRect() {
    return ui.Rect.fromLTWH(x, y, width, height);
  }

  factory Rectangle.fromJson(Map<String, dynamic> json) {
    return Rectangle(json["x"].toDouble(), json["y"].toDouble(), json["width"].toDouble(), json["height"].toDouble());
  }

  @override Map<String, dynamic> toMap() {
    return {
      "type": "RECTANGLE",
      "x": x,
      "y": y,
      "width": width,
      "height": height,
    };
  }

  @override Rectangle get rectangle {
    return this;
  }
}

class Circle extends Shape {
  final double x;
  final double y;
  final double radius;

  const Circle(this.x, this.y, this.radius);
}

class Annotation {
  final List<Label> labels;
  final Shape shape;

  const Annotation(this.labels, this.shape);

  factory Annotation.fromJson(Map<String, dynamic> output) {
    return Annotation(
      List<Label>.from(output["labels"].map((l) => Label.fromJson(l))),
      Shape.fromJson(output["shape"])
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "labels": labels.map((l) => l.toMap()).toList(),
      "shape": shape.toMap()
    };
  }
}

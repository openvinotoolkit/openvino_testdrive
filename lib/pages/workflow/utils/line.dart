import 'package:flutter/material.dart';


class Line {
  List<LineSegment> segments;

  Line({required this.segments});

  factory Line.betweenTwoPoints(Offset from, Axis fromDirection, Offset to, Axis toDirection) {
    // Options:
    // S: when input preference and output preference matches
    // ----
    //    |
    //    -----
    //
    // L: when input and output preferences dont match
    // ----
    //    |
    //    |


    if (fromDirection != toDirection) {
      // L
      final cornerPoint = findCornerPoint(from, to, fromDirection);
      return Line(
        segments: [
          LineSegment(from: from, to: cornerPoint),
          LineSegment(from: cornerPoint, to: to),
        ]
      );
    } else {
      final halfwayPoint = (to + from) / 2;

      final cornerPoint1 = findCornerPoint(from, halfwayPoint, fromDirection);
      final cornerPoint2 = findCornerPoint(to, halfwayPoint, toDirection);

      return Line(
        segments: [
          LineSegment(from: from, to: cornerPoint1),
          LineSegment(from: cornerPoint1, to: cornerPoint2),
          LineSegment(from: cornerPoint2, to: to),
        ]
      );
    }
  }

  static Offset findCornerPoint(Offset from, Offset to, Axis direction) {
    return Offset(
        direction == Axis.horizontal ? to.dx : from.dx,
        direction == Axis.horizontal ? from.dy : to.dy,
    );
  }

  //static otherDirectory(Axis dir) {
  //  return dir == Axis.horizontal ? Axis.vertical : Axis.horizontal;
  //}
}

class LineSegment {
  final Offset from;
  final Offset to;

  LineSegment({
      required this.from,
      required this.to,
  });
}

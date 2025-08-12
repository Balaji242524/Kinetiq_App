import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class PosePainter extends CustomPainter {
  final ui.Image image;
  final List<Map<String, dynamic>> keypoints;

  PosePainter({required this.image, required this.keypoints});

  final List<List<int>> connections = [
    [11, 12], [11, 23], [12, 24], [23, 24],
    [11, 13], [13, 15], [12, 14], [14, 16],
    [23, 25], [25, 27], [24, 26], [26, 28],
    [0, 1], [1, 2], [2, 3], [3, 7],
    [0, 4], [4, 5], [5, 6], [6, 8],
    [9, 10]
  ];

  @override
  void paint(Canvas canvas, Size size) {

    final linePaint = Paint()
      ..color = const Color(0xFF00B0FF)
      ..strokeWidth = 15.0
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..color = const Color(0xFFF50057) 
      ..strokeWidth = 10.0;



    final imagePaint = Paint();
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final src = Offset.zero & imageSize;
    final dst = Offset.zero & size;
    canvas.drawImageRect(image, src, dst, imagePaint);

    for (var connection in connections) {
      final p1Index = connection[0];
      final p2Index = connection[1];

      if (p1Index < keypoints.length && p2Index < keypoints.length) {
        final p1 = keypoints[p1Index];
        final p2 = keypoints[p2Index];

        final dx1 = p1['x'] * size.width;
        final dy1 = p1['y'] * size.height;
        final dx2 = p2['x'] * size.width;
        final dy2 = p2['y'] * size.height;

        canvas.drawLine(Offset(dx1, dy1), Offset(dx2, dy2), linePaint);
      }
    }

    for (var point in keypoints) {
      final dx = point['x'] * size.width;
      final dy = point['y'] * size.height;
      canvas.drawCircle(Offset(dx, dy), 5, pointPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
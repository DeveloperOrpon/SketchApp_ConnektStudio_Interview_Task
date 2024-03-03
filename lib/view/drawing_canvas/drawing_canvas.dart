import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:provider/provider.dart';
import 'package:sketch_app/main.dart';
import 'package:sketch_app/view/drawing_canvas/controller/canvasProvider.dart';
import 'package:sketch_app/view/drawing_canvas/models/drawing_mode.dart';
import 'package:sketch_app/view/drawing_canvas/models/sketch.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DrawingCanvas extends StatelessWidget {
  final double height;
  final double width;
  final AnimationController sideBarController;
  const DrawingCanvas({
    Key? key,
    required this.height,
    required this.width,
    required this.sideBarController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CanvasProvider>(builder: (context, canvasProvider, child) {
      return MouseRegion(
        cursor: SystemMouseCursors.precise,
        child: Stack(
          children: [
            buildAllSketches(context, canvasProvider),
            buildCurrentPath(context, canvasProvider),
          ],
        ),
      );
    });
  }

  void onPointerDown(PointerDownEvent details, BuildContext context,
      CanvasProvider canvasProvider) {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.position);
    canvasProvider.currentSketch = Sketch.fromDrawingMode(
      Sketch(
        points: [offset],
        size: canvasProvider.drawingMode == DrawingMode.eraser
            ? canvasProvider.strokeSize.toDouble()
            : canvasProvider.strokeSize.toDouble(),
        color: canvasProvider.drawingMode== DrawingMode.eraser
            ? kCanvasColor
            : Colors.black,
        sides: 3,
      ),
      canvasProvider.drawingMode,
      canvasProvider.filled,
    );
  }

  void onPointerMove(PointerMoveEvent details, BuildContext context,
      CanvasProvider canvasProvider) {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.position);
    final points = List<Offset>.from(canvasProvider.currentSketch?.points ?? [])
      ..add(offset);

    canvasProvider.currentSketch = Sketch.fromDrawingMode(
      Sketch(
        points: points,
        size: canvasProvider.drawingMode == DrawingMode.eraser
            ? canvasProvider.strokeSize.toDouble()
            : canvasProvider.strokeSize.toDouble(),
        color:canvasProvider.drawingMode== DrawingMode.eraser
            ? kCanvasColor
            : Colors.black,
        sides: 3,
      ),
      canvasProvider.drawingMode,
      canvasProvider.filled,
    );
  }

  void onPointerUp(PointerUpEvent details, CanvasProvider canvasProvider) {
    log("OnPointerAUp: ${canvasProvider.drawingMode}");
    canvasProvider.sketchesNotifier = List<Sketch>.from(canvasProvider.sketchesNotifier)
      ..add(canvasProvider.currentSketch!);
    canvasProvider.currentSketch = Sketch.fromDrawingMode(
      Sketch(
        points: [],
        size: canvasProvider.drawingMode == DrawingMode.eraser
            ? canvasProvider.strokeSize.toDouble()
            : canvasProvider.strokeSize.toDouble(),
        color: canvasProvider.drawingMode== DrawingMode.eraser
            ? kCanvasColor
            : Colors.black,
        sides:3,
      ),
      canvasProvider.drawingMode,
      canvasProvider.filled,
    );
  }

  Widget buildAllSketches(BuildContext context, CanvasProvider canvasProvider) {
    return SizedBox(
      height: height,
      width: width,
      child: RepaintBoundary(
        key: canvasProvider.canvasGlobalKey,
        child: Container(
          height: height,
          width: width,
          color: kCanvasColor,
          child: CustomPaint(
            painter: SketchPainter(
              sketches: canvasProvider.sketchesNotifier,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCurrentPath(BuildContext context, CanvasProvider canvasProvider) {
    return Listener(
      onPointerDown: (details) =>
          onPointerDown(details, context, canvasProvider),
      onPointerMove: (details) =>
          onPointerMove(details, context, canvasProvider),
      onPointerUp: (event) => onPointerUp(event, canvasProvider),
      child: RepaintBoundary(
        child: SizedBox(
          height: height,
          width: width,
          child: CustomPaint(
            painter: SketchPainter(
              sketches: canvasProvider.currentSketch == null ? [] : [canvasProvider.currentSketch!],
            ),
          ),
        ),
      ),
    );
  }
}

class SketchPainter extends CustomPainter {
  final List<Sketch> sketches;
  final Image? backgroundImage;

  const SketchPainter({
    Key? key,
    this.backgroundImage,
    required this.sketches,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundImage != null) {
      canvas.drawImageRect(
        backgroundImage!,
        Rect.fromLTWH(
          0,
          0,
          backgroundImage!.width.toDouble(),
          backgroundImage!.height.toDouble(),
        ),
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint(),
      );
    }
    for (Sketch sketch in sketches) {
      final points = sketch.points;
      if (points.isEmpty) return;

      final path = Path();

      path.moveTo(points[0].dx, points[0].dy);
      if (points.length < 2) {
        // If the path only has one line, draw a dot.
        path.addOval(
          Rect.fromCircle(
            center: Offset(points[0].dx, points[0].dy),
            radius: 1,
          ),
        );
      }

      for (int i = 1; i < points.length - 1; ++i) {
        final p0 = points[i];
        final p1 = points[i + 1];
        path.quadraticBezierTo(
          p0.dx,
          p0.dy,
          (p0.dx + p1.dx) / 2,
          (p0.dy + p1.dy) / 2,
        );
      }

      Paint paint = Paint()
        ..color = sketch.color
        ..strokeCap = StrokeCap.round;

      if (!sketch.filled) {
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = sketch.size;
      }

      // define first and last points for convenience
      Offset firstPoint = sketch.points.first;
      Offset lastPoint = sketch.points.last;

      // create rect to use rectangle and circle
      Rect rect = Rect.fromPoints(firstPoint, lastPoint);

      // Calculate center point from the first and last points
      Offset centerPoint = (firstPoint / 2) + (lastPoint / 2);

      // Calculate path's radius from the first and last points
      double radius = (firstPoint - lastPoint).distance / 2;

      if (sketch.type == SketchType.scribble) {
        canvas.drawPath(path, paint);
      } else if (sketch.type == SketchType.square) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(5)),
          paint,
        );
      } else if (sketch.type == SketchType.line) {
        canvas.drawLine(firstPoint, lastPoint, paint);
      } else if (sketch.type == SketchType.circle) {
        canvas.drawOval(rect, paint);
        // Uncomment this line if you need a PERFECT CIRCLE
        // canvas.drawCircle(centerPoint, radius , paint);
      } else if (sketch.type == SketchType.polygon) {
        Path polygonPath = Path();
        int sides = sketch.sides;
        var angle = (math.pi * 2) / sides;

        double radian = 0.0;

        Offset startPoint =
            Offset(radius * math.cos(radian), radius * math.sin(radian));

        polygonPath.moveTo(
          startPoint.dx + centerPoint.dx,
          startPoint.dy + centerPoint.dy,
        );
        for (int i = 1; i <= sides; i++) {
          double x = radius * math.cos(radian + angle * i) + centerPoint.dx;
          double y = radius * math.sin(radian + angle * i) + centerPoint.dy;
          polygonPath.lineTo(x, y);
        }
        polygonPath.close();
        canvas.drawPath(polygonPath, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SketchPainter oldDelegate) {
    return oldDelegate.sketches != sketches;
  }
}

library flutter_plot;

import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';
import 'package:meta/meta.dart';

/// Plot is a [StatelessWidget]
/// 
/// A [CustomPaint] is used to draw the Plot,
/// and the CustomPaint is wrapped in a [Container]
/// so that a user can provide height constraints and layout the
/// plot like they would other widgets. The plot takes all the
/// width that is available.
class Plot extends StatelessWidget {
  
  /// Widget height
  final double height;

  /// The dataset
  final List<Point> data;

  final PlotStyle style;

  /// gridSize determines how the grid is drawn
  /// 
  /// dx = x-width and dy = y-width.
  final Offset gridSize;

  /// Padding so that labels and text is visible
  /// 
  /// This is a known issue that someone more clever could help resolve.
  /// Ideally, padding should be calculated based upon the width/height of labels and 
  /// the xWindow/yWindow of the dataset, however, I'm unsure how to extract text width so
  /// that I may calculate padding.
  final EdgeInsets padding;

  /// Title to be displayed on the x-axis
  final String xTitle;

  /// Title to be displayed on the y-axis
  final String yTitle;

  Plot({
    this.height = 200.0,
    @required this.data,
    @required this.style,
    @required this.gridSize,
    @required this.padding,
    this.xTitle,
    this.yTitle,
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: this.height,
      padding: this.padding,
      alignment: Alignment.center,
      child: new CustomPaint(
        size: Size.infinite,
        painter: new _PlotPainter(
          points: this.data,
          style: this.style,
          gridSize: this.gridSize,
          xTitle: this.xTitle,
          yTitle: this.yTitle,
        ),
      ),
    );
  }

}

class _PlotPainter extends CustomPainter {
  final List<Point> points;
  final PlotStyle style;
  final Offset gridSize;
  final String xTitle;
  final String yTitle;

  // Used for determing the window
  double minX, maxX, minY, maxY, windowWidth, windowHeight;

  _PlotPainter({
    this.points,
    this.style,
    this.gridSize,
    this.xTitle,
    this.yTitle,
  }) : super() {
    assert(this.points != null && points.length > 0);
    this.points.sort((a, b) => a.x.compareTo(b.x));
    minX =
        (this.points.first.x > 0.0) ? 0.0 : this.points.first.x - gridSize.dx;
    maxX = (this.points.last.x < 0.0) ? 0.0 : this.points.last.x + gridSize.dx;
    this.points.sort((a, b) => a.y.compareTo(b.y));
    minY =
        (this.points.first.y > 0.0) ? 0.0 : this.points.first.y - gridSize.dy;
    maxY = (this.points.last.y < 0.0) ? 0.0 : this.points.last.y + gridSize.dy;
    windowWidth = maxX.abs() + minX.abs();
    windowHeight = maxY.abs() + minY.abs();
  }

  @override
  void paint(Canvas canvas, Size size) {
    Offset origin = _scalePoint(const Point(0.0, 0.0), size);

    // DRAWING GRIDLINES
    Paint gridPaint = new Paint();
    gridPaint.color = style.gridline ?? const Color(0x000000);
    gridPaint.style = PaintingStyle.stroke;
    gridPaint.strokeWidth = 1.0;

    int xGridlineCount = (windowWidth / gridSize.dx).round();
    int yGridlineCount = (windowHeight / gridSize.dy).round();

    for (int i = 0; i < xGridlineCount; i += 1) {
      // Routine for drawing xGridlines and xLabels
      drawLineAndLabel(double j) {
        Offset start = _scalePoint(new Point(j, 0), size);
        _drawXLabel((j).toString(), canvas, start.dx, origin.dy, size);
        if (style.gridline != null) {
          canvas.drawLine(new Offset(start.dx, 0.0),
              new Offset(start.dx, size.height), gridPaint);
        }
      }

      double x = i * gridSize.dx;
      if (-x >= minX && -x < 0) drawLineAndLabel(-x);
      if (x <= maxX && x >= 0) drawLineAndLabel(x);
    }

    for (int i = 0; i < yGridlineCount; i += 1) {
      // Routine for drawing yGridlines and yLabels
      drawLineAndLabel(double j) {
        Offset start = _scalePoint(new Point(minX, j), size);
        _drawYLabel((j).toString(), canvas, origin.dx, start.dy, size);
        if (style.gridline != null) {
          canvas.drawLine(new Offset(0.0, start.dy),
              new Offset(size.width, start.dy), gridPaint);
        }
      }

      double y = i * gridSize.dy;
      if (-y >= minY && -y < 0) drawLineAndLabel(-y);
      if (y <= maxY && y >= 0) drawLineAndLabel(y);
    }

    // DRAW xTitle
    if (xTitle != null) {
      TextPainter label = new TextPainter(
          text: new TextSpan(
            text: xTitle,
            style: this.style.textStyle ?? this.style.textStyle,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          textDirection: TextDirection.ltr);
      label.layout(maxWidth: size.width, minWidth: size.width);
      Offset labelPos = new Offset(0.0, size.height + 2 * label.height);
      label.paint(canvas, labelPos);
    }

    // DRAW yTitle
    if (yTitle != null) {
      TextPainter label = new TextPainter(
          text: new TextSpan(
            text: yTitle,
            style: this.style.textStyle,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          textDirection: TextDirection.ltr);
      label.layout(maxWidth: size.width, minWidth: size.width);
      Offset labelPos = new Offset(-1.5 * size.height, -3.5 * label.height);
      canvas.save();
      canvas.rotate(-PI / 2);
      label.paint(canvas, labelPos);
      canvas.restore();
    }

    // DRAWING EACH AXIS
    if (style.axis != null) {
      Paint axisPaint = new Paint();
      axisPaint.color = style.axis;
      axisPaint.style = PaintingStyle.stroke;
      axisPaint.strokeWidth = style.axisStrokeWidth;
      // Draw X Axis
      canvas.drawLine(new Offset(0.0, origin.dy),
          new Offset(size.width, origin.dy), axisPaint);
      // Draw Y Axis
      canvas.drawLine(new Offset(origin.dx, 0.0),
          new Offset(origin.dx, size.height), axisPaint);
    }

    // DRAWING TRACE LINES
    if (style.trace) {
      Paint traceLinePaint = new Paint();
      traceLinePaint.color =
          style.traceColor != null ? style.traceColor : style.secondary;
      traceLinePaint.strokeWidth = style.traceStokeWidth;
      traceLinePaint.style = PaintingStyle.fill;
      for (int i = 0; i < this.points.length; i++) {
        bool isLastPoint = (i + 1) == this.points.length;
        var firstPoint = _scalePoint(this.points[i], size);
        if (!isLastPoint) {
          var secondPoint = _scalePoint(this.points[i + 1], size);
          canvas.drawLine(
            firstPoint,
            secondPoint,
            traceLinePaint,
          );
        }
        if (isLastPoint && style.traceClose && this.points.length > 2) {
          var secondPoint = _scalePoint(this.points[0], size);
          canvas.drawLine(
            firstPoint,
            secondPoint,
            traceLinePaint,
          );
        }
      }
    }

    // DRAWING THE POINTS
    Paint circlePaint = new Paint();
    circlePaint.color = style.primary;
    circlePaint.style = PaintingStyle.fill;
    Paint outlinePaint = new Paint();
    outlinePaint.color = style.secondary;
    outlinePaint.style = PaintingStyle.stroke;
    outlinePaint.strokeWidth = style.outlineRadius;
    this.points.forEach((Point p) {
      Offset point = _scalePoint(p, size);
      canvas.drawCircle(point, style.pointRadius, circlePaint);
      if (style.outlineRadius > 0.0) {
        canvas.drawCircle(point, style.pointRadius, outlinePaint);
      }

      // DRAWING POINT COORDINATES
      if (style.showCoordinates) {
        TextPainter coordlabel = new TextPainter(
            text: new TextSpan(
              text: "(${p.x}, ${p.y})",
              style: new TextStyle(
                color: Colors.white,
                fontSize: 10.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            textDirection: TextDirection.ltr);
        coordlabel.layout(maxWidth: 192.0, minWidth: 24.0);
        Offset labelPos = new Offset(point.dx - coordlabel.width / 2,
            point.dy - (coordlabel.height / 2) - 16.0);
        Offset backLabelTL =
            new Offset(point.dx - (coordlabel.width / 2) - 6, point.dy - 6);
        Offset backLabelBR =
            new Offset(point.dx + (coordlabel.width / 2) + 6, point.dy - 26.0);
        Rect rect = new Rect.fromPoints(backLabelTL, backLabelBR);
        RRect rRect = new RRect.fromRectAndRadius(rect, Radius.circular(10.0));
        Paint backLabelPaint = new Paint();
        backLabelPaint.color = Colors.grey;
        backLabelPaint.style = PaintingStyle.fill;
        canvas.drawRRect(rRect, backLabelPaint);
        coordlabel.paint(canvas, labelPos);
      }
    });
  }

  bool shouldRepaint(_PlotPainter oldDelegate) => true;

  Offset _scalePoint(Point p, Size size) {
    double scaledX = (size.width * (p.x - minX)) / (maxX - minX);
    double scaledY = size.height - (size.height * (p.y - minY)) / (maxY - minY);
    return new Offset(scaledX, scaledY);
  }

  void _drawXLabel(String text, Canvas canvas, double x, double y, Size size) {
    TextPainter label = new TextPainter(
        text: new TextSpan(
          text: text,
          style: this.style.textStyle,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        textDirection: TextDirection.ltr);
    label.layout(maxWidth: 20.0, minWidth: 10.0);
    Offset labelPos =
        new Offset(x - label.width / 2, size.height + label.height / 2);
    label.paint(canvas, labelPos);
  }

  void _drawYLabel(String text, Canvas canvas, double x, double y, Size size) {
    TextPainter label = new TextPainter(
        text: new TextSpan(
          text: text,
          style: this.style.textStyle,
        ),
        textAlign: TextAlign.right,
        maxLines: 1,
        textDirection: TextDirection.ltr);
    label.layout(maxWidth: 20.0, minWidth: 10.0);
    // Offset labelPos = new Offset(x-(label.width + 2.0), y + 3.0);
    Offset labelPos = new Offset(-label.width - 4.0, y - label.height / 2);
    label.paint(canvas, labelPos);
  }
}



/// PlotStyle is used to style a plot
class PlotStyle {
  /// Drawing radius of points
  ///
  /// Defaults to 2.0
  final double pointRadius;

  /// Drawing radius of point outlines
  ///
  /// Defaults to 0.0
  final double outlineRadius;

  /// Color to draw the points with
  ///
  /// Defaults to #FF0000FF (Blue)
  final Color primary;

  /// Color to draw outlines with
  ///
  /// Defaults to #FFFF0000 (Red)
  final Color secondary;

  /// Color to draw the gridlines
  ///
  /// If not provided, then the gridlines are not drawn.
  final Color gridline;

  /// Color to draw the axis
  ///
  /// If not provided, the axis is not drawn.
  final Color axis;

  /// Drawing width of the axis
  ///
  /// Defaults to 1.0
  final double axisStrokeWidth;

  /// [TextStyle] for the axis labels and titles
  final TextStyle textStyle;

  /// If true lines will be drawn between each consecutive point
  ///
  /// Defaluts to false
  bool trace;

  /// If true a line will be traced between the last point and the first
  ///
  /// Defaluts to false
  bool traceClose;

  /// Color to draw trace lines with
  ///
  /// Defaults to #FF0000FF (Blue)
  final Color traceColor;

  /// Trace line stroke width
  ///
  /// Defaults to 2.0
  final double traceStokeWidth;

  /// If true each point's coordinates will be displayed above each point
  ///
  /// Defaults to false
  bool showCoordinates;

  PlotStyle({
    this.pointRadius = 2.0,
    this.outlineRadius = 0.0,
    this.primary = const Color(0xFF0000FF),
    this.secondary = const Color(0xFFFF0000),
    this.gridline,
    this.axis,
    this.axisStrokeWidth = 1.0,
    this.trace = false,
    this.traceClose = false,
    this.traceColor,
    this.traceStokeWidth = 2.0,
    this.showCoordinates = false,
    @required this.textStyle,
  });
}

import 'package:flutter/material.dart';

class TrimEditorPainter extends CustomPainter {
  /// To define the start offset
  final Offset startPos;

  /// To define the end offset
  final Offset endPos;

  /// To define the horizontal length of the selected video area
  final double scrubberAnimationDx;

  final double editorHeight;
  final double editorWidth;

  /// For specifying a circular border radius
  /// to the corners of the trim area.
  /// By default it is set to `4.0`.
  final double borderRadius;

  /// For specifying a size to the start holder
  /// of the video trimmer area.
  /// By default it is set to `0.5`.
  final double startCircleSize;

  /// For specifying a size to the end holder
  /// of the video trimmer area.
  /// By default it is set to `0.5`.
  final double endCircleSize;

  /// For specifying the width of the border around
  /// the trim area. By default it is set to `3`.
  final double borderWidth;

  /// For specifying the width of the video scrubber
  final double scrubberWidth;

  /// For specifying whether to show the scrubber
  final bool showScrubber;

  /// For specifying a color to the border of
  /// the trim area. By default it is set to `Colors.white`.
  final Color borderPaintColor;

  /// For specifying a color to the circle.
  /// By default it is set to `Colors.white`
  final Color arrowPaintColor;

  /// For specifying a color to the video
  /// scrubber inside the trim area. By default it is set to
  /// `Colors.white`.
  final Color scrubberPaintColor;

  /// For drawing the trim editor slider
  ///
  /// The required parameters are [startPos], [endPos]
  /// & [scrubberAnimationDx]
  ///
  /// * [startPos] to define the start offset
  ///
  ///
  /// * [endPos] to define the end offset
  ///
  ///
  /// * [scrubberAnimationDx] to define the horizontal length of the
  /// selected video area
  ///
  ///
  /// The optional parameters are:
  ///
  /// * [startCircleSize] for specifying a size to the start holder
  /// of the video trimmer area.
  /// By default it is set to `0.5`.
  ///
  ///
  /// * [endCircleSize] for specifying a size to the end holder
  /// of the video trimmer area.
  /// By default it is set to `0.5`.
  ///
  ///
  /// * [borderRadius] for specifying a circular border radius
  /// to the corners of the trim area.
  /// By default it is set to `4.0`.
  ///
  ///
  /// * [borderWidth] for specifying the width of the border around
  /// the trim area. By default it is set to `3`.
  ///
  ///
  /// * [scrubberWidth] for specifying the width of the video scrubber
  ///
  ///
  /// * [showScrubber] for specifying whether to show the scrubber
  ///
  ///
  /// * [borderPaintColor] for specifying a color to the border of
  /// the trim area. By default it is set to `Colors.white`.
  ///
  ///
  /// * [arrowPaintColor] for specifying a color to the circle.
  /// By default it is set to `Colors.white`.
  ///
  ///
  /// * [scrubberPaintColor] for specifying a color to the video
  /// scrubber inside the trim area. By default it is set to
  /// `Colors.white`.
  ///
  TrimEditorPainter({
    required this.startPos,
    required this.endPos,
    required this.scrubberAnimationDx,
    required this.editorHeight,
    required this.editorWidth,
    this.startCircleSize = 0.5,
    this.endCircleSize = 0.5,
    this.borderRadius = 4,
    this.borderWidth = 3,
    this.scrubberWidth = 1,
    this.showScrubber = true,
    this.borderPaintColor = Colors.white,
    this.arrowPaintColor = Colors.white,
    this.scrubberPaintColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var borderPaint = Paint()
      ..color = borderPaintColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    var scrubberPaint = Paint()
      ..color = scrubberPaintColor
      ..strokeWidth = scrubberWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromPoints(startPos, endPos);
    final roundedRect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(0),
    );

    if (showScrubber) {
      if (scrubberAnimationDx.toInt() > startPos.dx.toInt()) {
        canvas.drawLine(
          Offset(scrubberAnimationDx, 0),
          Offset(scrubberAnimationDx, 0) + Offset(0, endPos.dy),
          scrubberPaint,
        );
      }
    }

    canvas.drawRRect(roundedRect, borderPaint);

    // Left transparent background
    var leftTransparentRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        0,
        startPos.dy + endPos.dy / 2 - 20.5,
        startPos.dx,
        editorHeight + 1,
      ),
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(
        leftTransparentRect,
        Paint()
          ..color = Colors.white.withOpacity(0.7)
          ..style = PaintingStyle.fill);

    // Right transparent background
    var rightTransparentRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        endPos.dx,
        endPos.dy - endPos.dy / 2 - 20.5,
        editorWidth - endPos.dx,
        editorHeight + 3,
      ),
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(
        rightTransparentRect,
        Paint()
          ..color = Colors.white.withOpacity(0.7)
          ..style = PaintingStyle.fill);

    // Paint left arrow background
    var leftBackgroundRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        startPos.dx - 20,
        startPos.dy + endPos.dy / 2 - 20.5,
        20,
        editorHeight + 3,
      ),
      topLeft: Radius.circular(borderRadius),
      bottomLeft: Radius.circular(borderRadius),
    );
    canvas.drawRRect(
        leftBackgroundRect,
        Paint()
          ..color = borderPaintColor
          ..style = PaintingStyle.fill);

    // Paint right arrow background
    var rightBackgroundRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        endPos.dx,
        endPos.dy - endPos.dy / 2 - 20.5,
        20,
        editorHeight + 3,
      ),
      topRight: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
    );
    canvas.drawRRect(
        rightBackgroundRect,
        Paint()
          ..color = borderPaintColor
          ..style = PaintingStyle.fill);

    // Paint left arrow ("<")
    var leftArrowPath = Path()
      ..moveTo(startPos.dx - 4, startPos.dy + endPos.dy / 2 - 10)
      ..lineTo(startPos.dx - 14, startPos.dy + endPos.dy / 2)
      ..lineTo(
          startPos.dx - 4, startPos.dy + endPos.dy / 2 + 10);
    canvas.drawPath(
        leftArrowPath,
        Paint()
          ..color = arrowPaintColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);

    // Paint right arrow (">")
    var rightArrowPath = Path()
      ..moveTo(endPos.dx + 5, endPos.dy - endPos.dy / 2 - 10)
      ..lineTo(endPos.dx + 15, endPos.dy - endPos.dy / 2)
      ..lineTo(endPos.dx + 5, endPos.dy - endPos.dy / 2 + 10);
    canvas.drawPath(
        rightArrowPath,
        Paint()
          ..color = arrowPaintColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

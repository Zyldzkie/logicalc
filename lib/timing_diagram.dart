import 'package:flutter/material.dart';

class TimingDiagram extends StatelessWidget {
  final List<String> variables;
  final List<List<bool>> combinations;
  final List<String> subExpressions;
  final List<List<bool>> subResults;
  final List<bool> results;
  final String expression;

  const TimingDiagram({
    super.key,
    required this.variables,
    required this.combinations,
    required this.results,
    required this.subExpressions,
    required this.subResults,
    required this.expression,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (variables.length + subExpressions.length + 1) * 80.0,
      width: double.infinity,
      child: CustomPaint(
        painter: TimingDiagramPainter(
          variables: variables,
          combinations: combinations,
          results: results,
          subExpressions: subExpressions,
          subResults: subResults,
          expression: expression,
        ),
      ),
    );
  }
}

class TimingDiagramPainter extends CustomPainter {
  final List<String> variables;
  final List<List<bool>> combinations;
  final List<String> subExpressions;
  final List<List<bool>> subResults;
  final List<bool> results;
  final String expression;

  TimingDiagramPainter({
    required this.variables,
    required this.combinations,
    required this.results,
    required this.subExpressions,
    required this.subResults,
    required this.expression,
  });

  void _drawSignal({
    required Canvas canvas,
    required TextPainter textPainter,
    required String label,
    required List<bool> values,
    required double baseY,
    required double leftMargin,
    required double xStep,
    required Paint paint,
    Color color = Colors.black,
  }) {
    final double signalHeight = 40.0;
    final double highY = baseY - signalHeight/2;
    final double lowY = baseY + signalHeight/2;

    // Draw label
    textPainter.text = TextSpan(
      text: label,
      style: TextStyle(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, baseY - textPainter.height / 2));

    // Draw "1" and "0" labels
    textPainter.text = TextSpan(
      text: '1',
      style: TextStyle(
        color: color,
        fontSize: 12,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(leftMargin - 20, highY - textPainter.height / 2));

    textPainter.text = TextSpan(
      text: '0',
      style: TextStyle(
        color: color,
        fontSize: 12,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(leftMargin - 20, lowY - textPainter.height / 2));

    // Draw signal
    Path path = Path();
    bool firstValue = values[0];
    double currentY = firstValue ? highY : lowY;
    path.moveTo(leftMargin, currentY);

    for (int i = 0; i < values.length; i++) {
      double x = leftMargin + i * xStep;
      bool value = values[i];
      double targetY = value ? highY : lowY;
      
      if (i > 0 && values[i-1] != value) {
        path.lineTo(x, currentY);
        currentY = targetY;
        path.lineTo(x, currentY);
      }
      
      path.lineTo(x + xStep, currentY);
    }

    paint.color = color;
    canvas.drawPath(path, paint);
  }

  double _calculateLeftMargin(TextPainter textPainter) {
    double maxWidth = 0;
    
    // Check input variables
    for (String variable in variables) {
      textPainter.text = TextSpan(
        text: variable,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      maxWidth = maxWidth < textPainter.width ? textPainter.width : maxWidth;
    }

    // Check sub-expressions
    for (String subExpr in subExpressions) {
      textPainter.text = TextSpan(
        text: subExpr,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      maxWidth = maxWidth < textPainter.width ? textPainter.width : maxWidth;
    }

    // Check final expression
    textPainter.text = TextSpan(
      text: expression,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    maxWidth = maxWidth < textPainter.width ? textPainter.width : maxWidth;

    // Add padding for the labels and "1"/"0" indicators
    return maxWidth + 40.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final double ySpacing = 80.0;
    final double leftMargin = _calculateLeftMargin(textPainter);
    final double rightMargin = 20.0;
    final double xStep = (size.width - leftMargin - rightMargin) / combinations.length;

    // Draw input variables
    for (int i = 0; i < variables.length; i++) {
      _drawSignal(
        canvas: canvas,
        textPainter: textPainter,
        label: variables[i],
        values: combinations.map((combo) => combo[i]).toList(),
        baseY: i * ySpacing + 40.0,
        leftMargin: leftMargin,
        xStep: xStep,
        paint: paint,
      );
    }

    // Draw sub-expressions
    for (int i = 0; i < subExpressions.length; i++) {
      _drawSignal(
        canvas: canvas,
        textPainter: textPainter,
        label: subExpressions[i],
        values: subResults.map((result) => result[i]).toList(),
        baseY: (variables.length + i) * ySpacing + 40.0,
        leftMargin: leftMargin,
        xStep: xStep,
        paint: paint,
        color: Colors.blue,
      );
    }

    // Draw final result
    _drawSignal(
      canvas: canvas,
      textPainter: textPainter,
      label: expression,
      values: results,
      baseY: (variables.length + subExpressions.length) * ySpacing + 40.0,
      leftMargin: leftMargin,
      xStep: xStep,
      paint: paint,
      color: Colors.red,
    );

    // Draw time divisions
    paint.color = Colors.grey;
    paint.strokeWidth = 1.0;
    for (int i = 0; i <= combinations.length; i++) {
      double x = leftMargin + i * xStep;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, (variables.length + subExpressions.length + 1) * ySpacing),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 
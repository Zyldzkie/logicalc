import 'package:flutter/material.dart';

class TimingDiagram extends StatelessWidget {
  final List<String> variables;
  final List<List<bool>> combinations;
  final List<bool> results;

  const TimingDiagram({
    super.key,
    required this.variables,
    required this.combinations,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (variables.length + 1) * 80.0, // Increased height per signal
      width: double.infinity,
      child: CustomPaint(
        painter: TimingDiagramPainter(
          variables: variables,
          combinations: combinations,
          results: results,
        ),
      ),
    );
  }
}

class TimingDiagramPainter extends CustomPainter {
  final List<String> variables;
  final List<List<bool>> combinations;
  final List<bool> results;

  TimingDiagramPainter({
    required this.variables,
    required this.combinations,
    required this.results,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final double signalHeight = 40.0;
    final double ySpacing = 80.0;
    final double leftMargin = 80.0; // Increased for level labels
    final double rightMargin = 20.0;
    final double xStep = (size.width - leftMargin - rightMargin) / combinations.length;

    // Draw variable names and signals
    for (int i = 0; i < variables.length; i++) {
      double baseY = i * ySpacing + 40.0;
      double highY = baseY - signalHeight/2;
      double lowY = baseY + signalHeight/2;

      // Draw variable name
      textPainter.text = TextSpan(
        text: variables[i],
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(10, baseY - textPainter.height / 2));

      // Draw "1" and "0" labels
      textPainter.text = const TextSpan(
        text: '1',
        style: TextStyle(
          color: Colors.black,
          fontSize: 12,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(leftMargin - 20, highY - textPainter.height / 2));

      textPainter.text = const TextSpan(
        text: '0',
        style: TextStyle(
          color: Colors.black,
          fontSize: 12,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(leftMargin - 20, lowY - textPainter.height / 2));

      // Draw signal
      Path path = Path();
      bool firstValue = combinations[0][i];
      double currentY = firstValue ? highY : lowY;
      path.moveTo(leftMargin, currentY);

      for (int j = 0; j < combinations.length; j++) {
        double x = leftMargin + j * xStep;
        bool value = combinations[j][i];
        double targetY = value ? highY : lowY;
        
        if (j > 0 && combinations[j-1][i] != value) {
          path.lineTo(x, currentY);
          currentY = targetY;
          path.lineTo(x, currentY);
        }
        
        path.lineTo(x + xStep, currentY);
      }

      canvas.drawPath(path, paint);
    }

    // Draw result signal
    double baseY = variables.length * ySpacing + 40.0;
    double highY = baseY - signalHeight/2;
    double lowY = baseY + signalHeight/2;
    
    // Draw "Result" label
    textPainter.text = const TextSpan(
      text: 'Result',
      style: TextStyle(
        color: Colors.red,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, baseY - textPainter.height / 2));

    // Draw "1" and "0" labels for result
    textPainter.text = const TextSpan(
      text: '1',
      style: TextStyle(
        color: Colors.red,
        fontSize: 12,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(leftMargin - 20, highY - textPainter.height / 2));

    textPainter.text = const TextSpan(
      text: '0',
      style: TextStyle(
        color: Colors.red,
        fontSize: 12,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(leftMargin - 20, lowY - textPainter.height / 2));

    // Draw result waveform
    Path resultPath = Path();
    bool firstResult = results[0];
    double currentY = firstResult ? highY : lowY;
    resultPath.moveTo(leftMargin, currentY);

    for (int i = 0; i < results.length; i++) {
      double x = leftMargin + i * xStep;
      bool value = results[i];
      double targetY = value ? highY : lowY;
      
      if (i > 0 && results[i-1] != value) {
        resultPath.lineTo(x, currentY);
        currentY = targetY;
        resultPath.lineTo(x, currentY);
      }
      
      resultPath.lineTo(x + xStep, currentY);
    }

    paint.color = Colors.red;
    canvas.drawPath(resultPath, paint);

    // Draw time divisions
    paint.color = Colors.grey;
    paint.strokeWidth = 1.0;
    for (int i = 0; i <= combinations.length; i++) {
      double x = leftMargin + i * xStep;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, (variables.length + 1) * ySpacing),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 
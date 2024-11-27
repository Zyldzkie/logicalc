import 'package:flutter/material.dart';
import 'package:graphview/graphview.dart';

class CircuitDiagram extends StatelessWidget {
  final String expression;

  const CircuitDiagram({super.key, required this.expression});

  @override
  Widget build(BuildContext context) {
    final Graph graph = Graph()..isTree = true;
    final configuration = BuchheimWalkerConfiguration()
      ..siblingSeparation = 100
      ..levelSeparation = 100
      ..subtreeSeparation = 100
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT;
      
    final Algorithm algorithm = BuchheimWalkerAlgorithm(configuration, TreeEdgeRenderer(configuration));

    // Parse expression and create nodes
    Node outputNode = Node.Id('Output');
    _buildCircuitGraph(expression, graph, outputNode);

    return Container(
      height: 300,
      child: InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(100),
        minScale: 0.01,
        maxScale: 5.6,
        child: GraphView(
          graph: graph,
          algorithm: algorithm,
          paint: Paint()
            ..color = Colors.black
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke,
          builder: (Node node) {
            return _buildGateWidget(node);
          },
        ),
      ),
    );
  }

  void _buildCircuitGraph(String expr, Graph graph, Node parent) {
    // Parse expression and create appropriate gates
    if (expr.contains('∧')) {
      Node andGate = Node.Id('AND');
      graph.addEdge(parent, andGate);
      
      List<String> operands = expr.split('∧');
      for (String op in operands) {
        _buildCircuitGraph(op.trim(), graph, andGate);
      }
    } else if (expr.contains('∨')) {
      Node orGate = Node.Id('OR');
      graph.addEdge(parent, orGate);
      
      List<String> operands = expr.split('∨');
      for (String op in operands) {
        _buildCircuitGraph(op.trim(), graph, orGate);
      }
    } else if (expr.startsWith('¬')) {
      Node notGate = Node.Id('NOT');
      graph.addEdge(parent, notGate);
      
      _buildCircuitGraph(expr.substring(1), graph, notGate);
    } else {
      // Input variable
      Node input = Node.Id(expr);
      graph.addEdge(parent, input);
    }
  }

  Widget _buildGateWidget(Node node) {
    String gateType = node.key?.value as String;
    
    switch (gateType) {
      case 'AND':
        return _GateWidget(
          child: CustomPaint(
            painter: AndGatePainter(),
            size: const Size(50, 50),
          ),
        );
      case 'OR':
        return _GateWidget(
          child: CustomPaint(
            painter: OrGatePainter(),
            size: const Size(50, 50),
          ),
        );
      case 'NOT':
        return _GateWidget(
          child: CustomPaint(
            painter: NotGatePainter(),
            size: const Size(50, 50),
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(gateType),
        );
    }
  }
}

class _GateWidget extends StatelessWidget {
  final Widget child;

  const _GateWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent),
      ),
      child: child,
    );
  }
}

// Custom painters for logic gates
class AndGatePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.5, 0)
      ..arcToPoint(
        Offset(size.width * 0.5, size.height),
        radius: Radius.circular(size.height * 0.5),
        clockwise: true,
      )
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class OrGatePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.5,
        0,
        size.height,
      )
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.5,
        size.width,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.5,
        0,
        0,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NotGatePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.7, size.height * 0.5)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);

    // Draw the circle
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.5),
      size.width * 0.15,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 
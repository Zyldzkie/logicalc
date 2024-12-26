import 'package:flutter/material.dart';
import '../result_screen.dart';

class ExpressionInput extends StatefulWidget {
  const ExpressionInput({super.key});

  @override
  _ExpressionInputState createState() => _ExpressionInputState();
}

class _ExpressionInputState extends State<ExpressionInput> {
  final TextEditingController _controller = TextEditingController();
  String? _validationError;
  static const operators = ['•', '+', '↑', '↓', '⊕', '⊙'];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_validateExpression);
  }

  @override
  void dispose() {
    _controller.removeListener(_validateExpression);
    _controller.dispose();
    super.dispose();
  }

  void _validateExpression() {
    final expression = _controller.text;
    setState(() {
      // Check for empty expression
      if (expression.isEmpty) {
        _validationError = null;
        return;
      }

      // Check for adjacent operands (variables)
      for (int i = 0; i < expression.length - 1; i++) {
        final current = expression[i];
        final next = expression[i + 1];
        
        // If current char is a variable (A-C) and next char is also a variable
        if (isVariable(current) && isVariable(next)) {
          _validationError = 'Operands must be separated by operators';
          return;
        }
        
        // Check for negation placement
        if (current == '¬' && (i > 0 && isVariable(expression[i - 1]))) {
          _validationError = 'Negation must be placed before the operand';
          return;
        }
      }

      // Check for incomplete parentheses
      int parenthesesCount = 0;
      for (var char in expression.characters) {
        if (char == '(') parenthesesCount++;
        if (char == ')') parenthesesCount--;
        if (parenthesesCount < 0) {
          _validationError = 'Invalid parentheses order';
          return;
        }
      }
      if (parenthesesCount != 0) {
        _validationError = 'Incomplete parentheses';
        return;
      }

      // Check for mixing different operators without parentheses
      String? currentOperator;
      bool hasOperator = false;
      
      for (int i = 0; i < expression.length; i++) {
        if (operators.contains(expression[i]) && expression[i] != '¬') {
          if (!hasOperator) {
            currentOperator = expression[i];
            hasOperator = true;
          } 
        }
        // Reset operator check when encountering parentheses
        if (expression[i] == '(') {
          hasOperator = false;
          currentOperator = null;
        }
      }

      // Check for hanging operators
      if (operators.contains(expression[expression.length - 1])) {
        _validationError = 'Expression ends with an operator';
        return;
      }

      // Check for consecutive operators
      for (int i = 0; i < expression.length - 1; i++) {
        if (operators.contains(expression[i]) && 
            operators.contains(expression[i + 1]) &&
            expression[i] != '¬') { // Allow negation before other operators
          _validationError = 'Consecutive operators are not allowed';
          return;
        }
      }

      _validationError = null;
    });
  }

  // Helper method to check if a character is a variable
  bool isVariable(String char) {
    return RegExp(r'[A-C]').hasMatch(char);
  }

  void _handleKeyPress(String value) {
    setState(() {
      if (value == 'CLR') {
        _controller.clear();
      } else if (value == 'DEL') {
        final text = _controller.text;
        if (text.isNotEmpty) {
          _controller.text = text.substring(0, text.length - 1);
        }
      } else {
        _controller.text += value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equation Input', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Input your Equation:',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              readOnly: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Equation',
                errorText: _validationError,
              ),
            ),
            const SizedBox(height: 20),
            CustomKeyboard(onKeyPressed: _handleKeyPress),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _validationError == null && _controller.text.isNotEmpty
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ResultScreen(expression: _controller.text),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              child: const Text('Convert', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;

  const CustomKeyboard({super.key, required this.onKeyPressed});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildKey('A'),
        _buildKey('B'),
        _buildKey('C'),
        _buildKey('DEL', icon: Icons.backspace_outlined),
        _buildKey('•'),
        _buildKey('+'),
        _buildKey('¬'),
        _buildKey('↑'),
        _buildKey('↓'),
        _buildKey('⊕'),
        _buildKey('⊙'),
        _buildKey('('),
        _buildKey(')'),
        _buildKey('CLR'),
      ],
    );
  }

  Widget _buildKey(String label, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          onKeyPressed(label);
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        ),
        child: icon != null 
          ? Icon(icon, size: 24)
          : Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
      ),
    );
  }
} 
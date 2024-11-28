import 'package:flutter/material.dart';
import '../result_screen.dart';

class ExpressionInput extends StatefulWidget {
  const ExpressionInput({super.key});

  @override
  _ExpressionInputState createState() => _ExpressionInputState();
}

class _ExpressionInputState extends State<ExpressionInput> {
  final TextEditingController _controller = TextEditingController();

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
        title: const Text('Expression Input', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Input your Expression:',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              readOnly: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Expression',
              ),
            ),
            const SizedBox(height: 20),
            CustomKeyboard(onKeyPressed: _handleKeyPress),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(expression: _controller.text),
                  ),
                );
              },
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
        _buildKey('∧'),
        _buildKey('∨'),
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
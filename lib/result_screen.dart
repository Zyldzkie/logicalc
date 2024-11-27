import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';
import 'timing_diagram.dart';
import 'circuit_diagram.dart';
import 'dart:math' as Math;
import 'truth_table.dart';

class ResultScreen extends StatelessWidget {
  final String expression;

  const ResultScreen({super.key, required this.expression});

  List<String> _getVariables() {
    Set<String> variables = {};
    for (var char in expression.split('')) {
      if (char.toUpperCase().contains(RegExp(r'[A-C]'))) {
        variables.add(char);
      }
    }
    return variables.toList()..sort();
  }

  List<List<bool>> _generateCombinations(int numVars) {
    List<List<bool>> combinations = [];
    int totalRows = 1 << numVars;
    
    for (int i = 0; i < totalRows; i++) {
      List<bool> row = [];
      for (int j = numVars - 1; j >= 0; j--) {
        row.add((i & (1 << j)) != 0);
      }
      combinations.add(row);
    }
    return combinations;
  }

  String _convertToExpressionFormat(String input) {
    String result = input;

    // Create a map for operator replacements
    final Map<String, String> operators = {
      '¬': '!',
      '∧': ' && ',
      '∨': ' || ',
      '⊕': ' != ',
      '⊙': ' == ',
    };

    // Replace NOT operator first
    int index = 0;
    while (index < result.length) {
      if (result[index] == '¬') {
        if (index + 1 < result.length) {
          if (result[index + 1] == '(') {
            int count = 1;
            int endIndex = index + 2;
            while (count > 0 && endIndex < result.length) {
              if (result[endIndex] == '(') count++;
              if (result[endIndex] == ')') count--;
              endIndex++;
            }
            if (endIndex <= result.length) {
              result = result.substring(0, index) +
                  '!(' +
                  result.substring(index + 2, endIndex - 1) +
                  ')' +
                  result.substring(endIndex - 1);
            }
          } else {
            result = result.substring(0, index) +
                '!' +
                result[index + 1] +
                (index + 2 < result.length ? result.substring(index + 2) : '');
          }
        }
      }
      index++;
    }

    // Handle NAND (↑) with parentheses
    final nandRegex = RegExp(r'([A-Z]|\([^)]+\))\s*↑\s*([A-Z]|\([^)]+\))');
    while (result.contains('↑')) {
      result = result.replaceAllMapped(nandRegex, (match) {
        String left = match.group(1)!;
        String right = match.group(2)!;
        return '!($left && $right)';
      });
    }

    // Handle NOR (↓) with parentheses
    final norRegex = RegExp(r'([A-Z]|\([^)]+\))\s*↓\s*([A-Z]|\([^)]+\))');
    while (result.contains('↓')) {
      result = result.replaceAllMapped(norRegex, (match) {
        String left = match.group(1)!;
        String right = match.group(2)!;
        return '!($left || $right)';
      });
    }

    // Replace other operators
    for (var entry in operators.entries) {
      if (entry.key != '¬') { // Skip NOT as we already handled it
        result = result.replaceAll(entry.key, entry.value);
      }
    }

    // Add parentheses around the entire expression if not already present
    if (!result.startsWith('(')) {
      result = '($result)';
    }

    print('Converted expression: $result'); // Debug print
    return result;
  }

  bool _evaluateExpression(List<bool> values, List<String> variables) {
    try {
      // Create context with variable values
      Map<String, dynamic> context = {};
      for (int i = 0; i < variables.length; i++) {
        context[variables[i]] = values[i];
      }

      // Convert and evaluate expression
      String expressionStr = _convertToExpressionFormat(expression);

      print(expressionStr);
      
      // Handle NAND and NOR after conversion
      if (expressionStr.contains(' nand ')) {
        expressionStr = '!(${expressionStr.replaceAll(' nand ', ' && ')})'; // Negate the AND expression
      }
      if (expressionStr.contains(' nor ')) {
        expressionStr = '!(${expressionStr.replaceAll(' nor ', ' || ')})';   // Negate the OR expression
      }

      print(expressionStr);

      final evaluator = const ExpressionEvaluator();
      final expr = Expression.parse(expressionStr);
      return evaluator.eval(expr, context) as bool;
    } catch (e) {
      print('Error evaluating expression: $e');
      print('Variables: $variables');
      print('Values: $values');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> variables = _getVariables();
    List<List<bool>> combinations = _generateCombinations(variables.length);
    List<bool> results = combinations.map(
      (combo) => _evaluateExpression(combo, variables)
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Table'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expression: $expression',
              style: const TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Truth Table',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 20),
            TruthTable(
              variables: variables,
              combinations: combinations,
              results: results,
            ),
            const SizedBox(height: 40),
            const Text(
              'Timing Diagram',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 20),
            TimingDiagram(
              variables: variables,
              combinations: combinations,
              results: results,
            ),
            const SizedBox(height: 40),
            const Text(
              'Logic Circuit',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 20),
            CircuitDiagram(expression: expression),
          ],
        ),
      ),
    );
  }
}
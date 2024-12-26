import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';
import 'timing_diagram.dart';
import 'circuit_diagram.dart';
import 'dart:math' as Math;
import 'truth_table.dart';
import 'models/expression_history.dart';
import 'services/history_service.dart';
import 'screens/expression_input.dart';
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

    final Map<String, String> operators = {
      '¬': '!',
      '∧': ' && ',
      '∨': ' || ',
      '⊕': ' != ',
      '⊙': ' == ',
    };

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
                  result.substring(endIndex);
            }
          } else {
            result = result.substring(0, index) +
                '!(' +
                result[index + 1] +
                ')' +
                result.substring(index + 2);
          }
        }
      }
      index++;
    }

    // Handle NAND (↑) with parentheses
    final nandRegex = RegExp(r'([A-Z]|\([^)]+\))\s*↑\s*(!?\([^)]+\)|!?[A-Z])');
    while (result.contains('↑')) {
      result = result.replaceAllMapped(nandRegex, (match) {
        String left = match.group(1)!;
        String right = match.group(2)!;
        return '!($left && $right)';
      });
    }

    // Handle NOR (↓) with parentheses
    final norRegex = RegExp(r'([A-Z]|\([^)]+\))\s*↓\s*(!?\([^)]+\)|!?[A-Z])');
    while (result.contains('↓')) {
      result = result.replaceAllMapped(norRegex, (match) {
        String left = match.group(1)!;
        String right = match.group(2)!;
        return '!($left || $right)';
      });
    }

    for (var entry in operators.entries) {
      if (entry.key != '¬') {
        result = result.replaceAll(entry.key, entry.value);
      }
    }

    if (!result.startsWith('(')) {
      result = '($result)';
    }

    print('Converted expression: $result');
    return result;
  }

  List<String> _getSubExpressions(String expr) {
    List<String> subExpressions = [];
    
    if (expr.contains('(')) {
      int start = 0;
      int count = 0;
      
      for (int i = 0; i < expr.length; i++) {
        if (expr[i] == '(') {
          if (count == 0) start = i;
          count++;
        } else if (expr[i] == ')') {
          count--;
          if (count == 0) {
            subExpressions.add(expr.substring(start + 1, i));
          }
        }
      }
    }
    
    return subExpressions;
  }

  List<List<bool>> _evaluateSubExpressions(List<List<bool>> combinations, List<String> variables) {
    List<String> subExpressions = _getSubExpressions(expression);
    List<List<bool>> subResults = [];
    
    for (var combo in combinations) {
      List<bool> rowResults = [];
      for (var subExpr in subExpressions) {
        rowResults.add(_evaluateExpression(combo, variables, subExpr));
      }
      subResults.add(rowResults);
    }
    
    return subResults;
  }

  bool _evaluateExpression(List<bool> values, List<String> variables, [String? customExpr]) {
    try {
      Map<String, dynamic> context = {};
      for (int i = 0; i < variables.length; i++) {
        context[variables[i]] = values[i];
      }
      
      String expressionStr = _convertToExpressionFormat(customExpr ?? expression);

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

  Future<void> _saveToHistory(String rawExpr, String convertedExpr) async {
    final entry = ExpressionHistory(
      rawExpression: rawExpr,
      convertedExpression: convertedExpr,
      timestamp: DateTime.now(),
    );
    await HistoryService.saveExpression(entry);
  }

  @override
  Widget build(BuildContext context) {
    List<String> variables = _getVariables();
    List<List<bool>> combinations = _generateCombinations(variables.length);
    List<String> subExpressions = _getSubExpressions(expression);
    List<List<bool>> subResults = _evaluateSubExpressions(combinations, variables);
    List<bool> finalResults = combinations.map(
      (combo) => _evaluateExpression(combo, variables)
    ).toList();

    String convertedExpr = _convertToExpressionFormat(expression);
    _saveToHistory(expression, convertedExpr); // Save to history

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tables and Diagrams'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Equation: $expression',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    subExpressions: subExpressions,
                    subResults: subResults,
                    results: finalResults,
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
                    results: finalResults,
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
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.home),
                    label: const Text('Go Home'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ),
                const SizedBox(width: 16), // Spacing between buttons
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Calculate Again'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => ExpressionInput(
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
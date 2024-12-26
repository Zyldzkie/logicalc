import 'package:flutter/material.dart';
import 'package:graphview/graphview.dart';
import '../circuit_diagram.dart';
import '../models/expression_history.dart';
import '../services/history_service.dart';
import '../truth_table.dart';
import '../timing_diagram.dart';
import 'package:expressions/expressions.dart';

class HistoryResultPage extends StatelessWidget {
  final String expression;

  const HistoryResultPage({
    super.key, 
    required this.expression,
  });

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
      '•': ' && ',
      '+': ' || ',
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

  List<String> _getSubExpressions(String expr) {
    List<String> subExpressions = [];
    
    // Handle negations first
    int index = 0;
    while (index < expr.length) {
      if (expr[index] == '¬') {
        if (index + 1 < expr.length) {
          if (expr[index + 1] == '(') {
            // Find matching closing parenthesis
            int count = 1;
            int endIndex = index + 2;
            while (count > 0 && endIndex < expr.length) {
              if (expr[endIndex] == '(') count++;
              if (expr[endIndex] == ')') count--;
              endIndex++;
            }
            if (endIndex <= expr.length) {
              String innerExpr = expr.substring(index + 2, endIndex - 1);
              String negationExpr = '¬(' + innerExpr + ')';
              if (!subExpressions.contains(negationExpr)) {
                subExpressions.add(negationExpr);
              }
            }
          } else {
            // Single variable negation
            String negationExpr = '¬' + expr[index + 1];
            if (!subExpressions.contains(negationExpr)) {
              subExpressions.add(negationExpr);
            }
          }
        }
      }
      index++;
    }
    
    // Handle other parenthesized expressions
    if (expr.contains('(')) {
      index = 0;
      int count = 0;
      
      for (int i = 0; i < expr.length; i++) {
        if (expr[i] == '(') {
          if (count == 0) index = i;
          count++;
        } else if (expr[i] == ')') {
          count--;
          if (count == 0) {
            String subExpr = expr.substring(index + 1, i);
            if (!subExpressions.contains(subExpr)) {
              subExpressions.add(subExpr);
            }
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
      
      if (expressionStr.contains(' nand ')) {
        expressionStr = '!(${expressionStr.replaceAll(' nand ', ' && ')})';
      }
      if (expressionStr.contains(' nor ')) {
        expressionStr = '!(${expressionStr.replaceAll(' nor ', ' || ')})';
      }

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
    List<String> subExpressions = _getSubExpressions(expression);
    List<List<bool>> subResults = _evaluateSubExpressions(combinations, variables);
    List<bool> finalResults = combinations.map(
      (combo) => _evaluateExpression(combo, variables)
    ).toList();

    String convertedExpr = _convertToExpressionFormat(expression);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tables and Diagrams'),
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            const Text(
              'Truth Table',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TruthTable(
              variables: variables,
              combinations: combinations,
              subExpressions: subExpressions,
              subResults: subResults,
              results: finalResults,
              expression: expression,
            ),
            const SizedBox(height: 40),
            const Text(
              'Timing Diagram',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TimingDiagram(
              variables: variables,
              combinations: combinations,
              results: finalResults,
              subExpressions: subExpressions,
              subResults: subResults,
              expression: expression,
            ),
            const SizedBox(height: 40),
            const Text(
              'Logic Circuit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            CircuitDiagram(expression: expression),
          ],
        ),
      ),
    );
  }
}

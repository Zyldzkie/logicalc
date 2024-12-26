import 'package:flutter/material.dart';

class TruthTable extends StatelessWidget {
  final List<String> variables;
  final List<List<bool>> combinations;
  final List<String> subExpressions;
  final List<List<bool>> subResults;
  final List<bool> results;
  final String expression;

  const TruthTable({
    super.key,
    required this.variables,
    required this.combinations,
    required this.subExpressions,
    required this.subResults,
    required this.results,
    required this.expression,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          ...variables.map((var_) => DataColumn(
            label: Text(var_, style: const TextStyle(fontWeight: FontWeight.bold)),
          )),
          ...subExpressions.map((expr) => DataColumn(
            label: Text(expr, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          )),
          DataColumn(
            label: Text(expression, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          ),
        ],
        rows: List.generate(
          combinations.length,
          (index) => DataRow(
            cells: [
              ...combinations[index].map((value) => DataCell(
                Text(value ? '1' : '0'),
              )),
              ...subResults[index].map((value) => DataCell(
                Text(value ? '1' : '0', style: const TextStyle(color: Colors.blue)),
              )),
              DataCell(
                Text(results[index] ? '1' : '0', style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';

class TruthTable extends StatelessWidget {
  final List<String> variables;
  final List<List<bool>> combinations;
  final List<bool> results;

  const TruthTable({
    super.key,
    required this.variables,
    required this.combinations,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          ...variables.map((var_) => DataColumn(
            label: Text(
              var_,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          )),
          DataColumn(
            label: Text(
              'Result',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ),
        ],
        rows: List.generate(
          combinations.length,
          (index) => DataRow(
            cells: [
              ...combinations[index].map((value) => DataCell(
                Text(value ? '1' : '0'),
              )),
              DataCell(
                Text(results[index] ? '1' : '0', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import '../models/expression_history.dart';
import '../services/history_service.dart';
import '../result_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'history_result_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<ExpressionHistory> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await HistoryService.getHistory();
    setState(() {
      _history = history;
    });
  }

  Future<void> _deleteEntry(int index) async {
    await HistoryService.deleteExpression(index);
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equation History'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              await HistoryService.clearHistory();
              _loadHistory();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final entry = _history[index];
          return Dismissible(
            key: Key(entry.timestamp.toString()),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) => _deleteEntry(index),
            child: ListTile(
              title: Text(entry.rawExpression),
              subtitle: Text(
                'Created: ${entry.timestamp.toString().split('.')[0]}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryResultPage(
                      expression: entry.rawExpression,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
} 
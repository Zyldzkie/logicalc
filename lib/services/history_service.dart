import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expression_history.dart';

class HistoryService {
  static const String _key = 'expression_history';

  static Future<void> saveExpression(ExpressionHistory expression) async {
    final prefs = await SharedPreferences.getInstance();
    List<ExpressionHistory> history = await getHistory();
    history.insert(0, expression); // Add new expression at the beginning
    
    // Convert to JSON
    final List<Map<String, dynamic>> jsonList = 
        history.map((e) => e.toJson()).toList();
    
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  static Future<List<ExpressionHistory>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_key);
    
    if (historyJson == null) return [];
    
    List<dynamic> jsonList = jsonDecode(historyJson);
    return jsonList
        .map((json) => ExpressionHistory.fromJson(json))
        .toList();
  }

  static Future<void> deleteExpression(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<ExpressionHistory> history = await getHistory();
    
    if (index >= 0 && index < history.length) {
      history.removeAt(index);
      final List<Map<String, dynamic>> jsonList = 
          history.map((e) => e.toJson()).toList();
      await prefs.setString(_key, jsonEncode(jsonList));
    }
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
} 
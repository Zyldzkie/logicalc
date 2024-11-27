class ExpressionHistory {
  final String rawExpression;
  final String convertedExpression;
  final DateTime timestamp;

  ExpressionHistory({
    required this.rawExpression,
    required this.convertedExpression,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'rawExpression': rawExpression,
    'convertedExpression': convertedExpression,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ExpressionHistory.fromJson(Map<String, dynamic> json) {
    return ExpressionHistory(
      rawExpression: json['rawExpression'],
      convertedExpression: json['convertedExpression'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
} 
class Transaction {
  final int? id;
  final double amount;
  final int categoryId;
  final String note;
  final DateTime date;
  final String type;

  Transaction({
    this.id,
    required this.amount,
    required this.categoryId,
    required this.note,
    required this.date,
    required this.type,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'],
        amount: (json['amount'] as num).toDouble(),
        categoryId: json['categoryId'],
        note: json['note'],
        date: DateTime.parse(json['date']),
        type: json['type'],
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'amount': amount,
        'categoryId': categoryId,
        'note': note,
        'date': date.toIso8601String(),
        'type': type,
      };
}
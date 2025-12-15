// lib/data/models/ingredient_model.dart
class Ingredient {
  final int? id;
  final String name;
  final double amount;
  final String unit;

  Ingredient({
    this.id,
    required this.name,
    required this.amount,
    required this.unit,
  });

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      unit: map['unit'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'unit': unit,
    };
  }

  // 🔥 Tambahkan copyWith agar bisa update ingredient saat edit
  Ingredient copyWith({
    int? id,
    String? name,
    double? amount,
    String? unit,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
    );
  }
}

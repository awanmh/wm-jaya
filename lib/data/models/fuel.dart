// lib/data/models/fuel.dart
class Fuel {
  final int? id;
  final String type;
  final double liters;
  final double pricePerLiter;
  final double total;
  final DateTime date;
  final bool reportGenerated;

  Fuel({
    this.id,
    required this.type,
    required this.liters,
    required this.pricePerLiter,
    required this.total,
    required this.date,
    this.reportGenerated = false,
  });

  factory Fuel.fromMap(Map<String, dynamic> map) => Fuel(
        id: map['id'],
        type: map['type'],
        liters: map['liters'].toDouble(),
        pricePerLiter: map['pricePerLiter'].toDouble(),
        total: map['total'].toDouble(),
        date: DateTime.parse(map['date']),
        reportGenerated: map['reportGenerated'] == 1,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'type': type,
        'liters': liters,
        'pricePerLiter': pricePerLiter,
        'total': total,
        'date': date.toIso8601String(),
        'reportGenerated': reportGenerated ? 1 : 0,
      };

  Fuel calculateFromPrice(double price) => Fuel(
        type: type,
        liters: price / pricePerLiter,
        pricePerLiter: pricePerLiter,
        total: price,
        date: date,
      );

  Fuel calculateFromLiters(double liters) => Fuel(
        type: type,
        liters: liters,
        pricePerLiter: pricePerLiter,
        total: liters * pricePerLiter,
        date: date,
      );
}
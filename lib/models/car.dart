/// 一款候选电动车的完整数据，对应 assets/cars.json 中的一条记录。
class Car {
  final String id;
  final String name;
  final String brand;
  final String priceRange;
  final String segment;
  final int priceMin;
  final int priceMax;
  final String category;
  final String batteryCapacity;
  final int rangeKm;
  final String fastCharge;
  final String suspension;
  final String smartDriving;
  final List<String> highlights;
  final List<String> weaknesses;
  final List<String> bestFor;

  const Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.priceRange,
    required this.segment,
    required this.priceMin,
    required this.priceMax,
    required this.category,
    required this.batteryCapacity,
    required this.rangeKm,
    required this.fastCharge,
    required this.suspension,
    required this.smartDriving,
    required this.highlights,
    required this.weaknesses,
    required this.bestFor,
  });

  factory Car.fromJson(Map<String, dynamic> j) => Car(
        id: j['id'] as String,
        name: j['name'] as String,
        brand: j['brand'] as String,
        priceRange: j['price_range'] as String,
        segment: j['segment'] as String? ?? '',
        priceMin: (j['price_min'] as num).toInt(),
        priceMax: (j['price_max'] as num).toInt(),
        category: j['category'] as String,
        batteryCapacity: j['battery_capacity'] as String,
        rangeKm: (j['range_km'] as num).toInt(),
        fastCharge: j['fast_charge'] as String,
        suspension: j['suspension'] as String,
        smartDriving: j['smart_driving'] as String,
        highlights: List<String>.from(j['highlights'] as List? ?? const []),
        weaknesses: List<String>.from(j['weaknesses'] as List? ?? const []),
        bestFor: List<String>.from(j['best_for'] as List? ?? const []),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'price_range': priceRange,
        'segment': segment,
        'price_min': priceMin,
        'price_max': priceMax,
        'category': category,
        'battery_capacity': batteryCapacity,
        'range_km': rangeKm,
        'fast_charge': fastCharge,
        'suspension': suspension,
        'smart_driving': smartDriving,
        'highlights': highlights,
        'weaknesses': weaknesses,
        'best_for': bestFor,
      };
}

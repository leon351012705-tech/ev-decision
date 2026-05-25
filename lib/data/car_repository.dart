import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/car.dart';

/// 从本地 assets/cars.json 读取预置车型数据。
class CarRepository {
  static List<Car>? _cache;

  static Future<List<Car>> loadCars() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/cars.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    _cache = decoded
        .map((e) => Car.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    return _cache!;
  }

  static Future<List<Car>> byIds(List<String> ids) async {
    final all = await loadCars();
    final map = {for (final c in all) c.id: c};
    return ids.map((id) => map[id]).whereType<Car>().toList();
  }

  /// 价格段分组，保持 PRD 中的展示顺序。
  static const List<String> segments = ['经济段', '主流段', '中高端'];
}

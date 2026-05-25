import 'package:flutter/foundation.dart';

import '../models/survey.dart';

/// 保存一次评估流程中的进行态：问卷答案 + 已选车型。
class AssessmentProvider extends ChangeNotifier {
  final Map<String, dynamic> _answers = {};
  final List<String> _selectedCarIds = [];

  static const int maxCars = 3;
  static const int minCars = 2;

  Map<String, dynamic> get answers => Map.unmodifiable(_answers);
  List<String> get selectedCarIds => List.unmodifiable(_selectedCarIds);

  dynamic answerFor(String questionId) => _answers[questionId];

  bool isAnswered(SurveyQuestion q) {
    final a = _answers[q.id];
    if (q.multi) return a is List && a.isNotEmpty;
    return a is String && a.isNotEmpty;
  }

  void setSingle(String questionId, String value) {
    _answers[questionId] = value;
    notifyListeners();
  }

  void toggleMulti(String questionId, String value, int maxSelect) {
    final list = (_answers[questionId] as List?)?.cast<String>() ?? <String>[];
    if (list.contains(value)) {
      list.remove(value);
    } else if (list.length < maxSelect) {
      list.add(value);
    }
    _answers[questionId] = list;
    notifyListeners();
  }

  bool isCarSelected(String carId) => _selectedCarIds.contains(carId);

  /// 返回 false 表示已达上限、未能选中。
  bool toggleCar(String carId) {
    if (_selectedCarIds.contains(carId)) {
      _selectedCarIds.remove(carId);
      notifyListeners();
      return true;
    }
    if (_selectedCarIds.length >= maxCars) return false;
    _selectedCarIds.add(carId);
    notifyListeners();
    return true;
  }

  bool get canGenerateReport =>
      _selectedCarIds.length >= minCars && _selectedCarIds.length <= maxCars;

  UserProfile buildProfile() => UserProfile.fromAnswers(_answers);

  void reset() {
    _answers.clear();
    _selectedCarIds.clear();
    notifyListeners();
  }
}

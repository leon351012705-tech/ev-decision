import 'dart:convert';

import 'ai_report.dart';
import 'survey.dart';

/// 一条评估记录，对应 SQLite 中 evaluations 表的一行。
///
/// 注：report 以 JSON 存于 report_markdown 列（沿用 PRD 表结构字段名）。
class EvaluationRecord {
  final int? id;
  final DateTime createdAt;
  final UserProfile profile;
  final List<String> selectedCarIds;
  final AiReport report;

  const EvaluationRecord({
    this.id,
    required this.createdAt,
    required this.profile,
    required this.selectedCarIds,
    required this.report,
  });

  String get recommendedCarId => report.recommendedCarId;

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'created_at': createdAt.toIso8601String(),
        'user_profile': jsonEncode(profile.toJson()),
        'selected_cars': jsonEncode(selectedCarIds),
        'report_markdown': jsonEncode(report.toJson()),
        'recommended_car_id': report.recommendedCarId,
      };

  factory EvaluationRecord.fromMap(Map<String, dynamic> m) => EvaluationRecord(
        id: m['id'] as int?,
        createdAt: DateTime.parse(m['created_at'] as String),
        profile: UserProfile.fromJson(
          jsonDecode(m['user_profile'] as String) as Map<String, dynamic>,
        ),
        selectedCarIds:
            (jsonDecode(m['selected_cars'] as String) as List).cast<String>(),
        report: AiReport.fromJson(
          jsonDecode(m['report_markdown'] as String) as Map<String, dynamic>,
        ),
      );
}

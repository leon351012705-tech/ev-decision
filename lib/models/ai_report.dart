/// 针对单款车、面向当前用户的分析结论。
class CarVerdict {
  final String carId;
  final String headline;
  final List<String> pros;
  final List<String> cons;

  const CarVerdict({
    required this.carId,
    required this.headline,
    required this.pros,
    required this.cons,
  });

  Map<String, dynamic> toJson() => {
        'car_id': carId,
        'headline': headline,
        'pros': pros,
        'cons': cons,
      };

  factory CarVerdict.fromJson(Map<String, dynamic> j) => CarVerdict(
        carId: j['car_id'] as String,
        headline: (j['headline'] as String?) ?? '',
        pros: List<String>.from(j['pros'] as List? ?? const []),
        cons: List<String>.from(j['cons'] as List? ?? const []),
      );
}

/// 一份决策报告：可能来自大模型，也可能来自本地兜底引擎。
class AiReport {
  final String conclusion;

  /// 按推荐优先级从高到低排序。
  final List<CarVerdict> ranking;
  final String finalAdvice;

  /// true = 大模型生成；false = 本地规则兜底。
  final bool aiGenerated;

  const AiReport({
    required this.conclusion,
    required this.ranking,
    required this.finalAdvice,
    this.aiGenerated = true,
  });

  String get recommendedCarId => ranking.first.carId;

  Map<String, dynamic> toJson() => {
        'conclusion': conclusion,
        'ranking': ranking.map((v) => v.toJson()).toList(),
        'final_advice': finalAdvice,
        'ai_generated': aiGenerated,
      };

  factory AiReport.fromJson(Map<String, dynamic> j) => AiReport(
        conclusion: (j['conclusion'] as String?) ?? '',
        ranking: (j['ranking'] as List? ?? const [])
            .map((e) => CarVerdict.fromJson(e as Map<String, dynamic>))
            .toList(),
        finalAdvice: (j['final_advice'] as String?) ?? '',
        aiGenerated: (j['ai_generated'] as bool?) ?? true,
      );
}

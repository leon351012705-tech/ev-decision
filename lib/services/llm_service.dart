import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/ai_report.dart';
import '../models/car.dart';
import '../models/survey.dart';
import 'llm_config.dart';

/// 调用大模型生成结构化决策报告。
class LlmService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 45),
    ),
  );

  /// 是否已配置 API Key。未配置时调用方应改用本地兜底。
  static bool get configured => LlmConfig.apiKey.trim().isNotEmpty;

  static const String _systemPrompt =
      '你是一位资深的新能源汽车选购顾问。你会基于用户的真实情况给出有针对性的'
      '购车建议，诚实指出每款车的短板，不做营销话术。';

  /// 调用大模型生成报告。失败时抛异常，由调用方兜底。
  static Future<AiReport> generateReport(
    UserProfile profile,
    List<Car> cars,
  ) async {
    final response = await _dio.post(
      LlmConfig.baseUrl,
      options: Options(
        headers: {
          'Authorization': 'Bearer ${LlmConfig.apiKey}',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': LlmConfig.model,
        'temperature': 0.6,
        'response_format': {'type': 'json_object'},
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {'role': 'user', 'content': _buildUserPrompt(profile, cars)},
        ],
      },
    );

    final content =
        response.data['choices'][0]['message']['content'] as String;
    final json = _extractJson(content);
    return _parseReport(json, cars);
  }

  static String _buildUserPrompt(UserProfile profile, List<Car> cars) {
    final carsJson = jsonEncode(cars.map((c) => c.toJson()).toList());
    return '''
请基于以下用户画像和候选车型，生成一份个性化的购车决策分析。

【用户画像】
- 主要用车场景：${profile.scenario}
- 日均行驶里程：${profile.dailyKm}
- 充电条件：${profile.charging}
- 预算区间：${profile.budget}
- 最在意：${profile.priorities.join('、')}

【候选车型】
$carsJson

【要求】
1. 必须结合用户的实际场景给出推荐，不要堆砌参数。
2. 评价要有针对性，例如：不能装家充的用户要重点关注快充能力。
3. pros / cons 用"对你来说""你"这样的第二人称，具体到这位用户。
4. 诚实指出每款车的短板，不做营销话术。
5. ranking 按推荐优先级从高到低排列，必须包含全部候选车型。

只输出 JSON，不要任何额外文字或解释，严格使用以下结构：
{
  "conclusion": "一句话结论，直接说最推荐哪款车、核心理由",
  "ranking": [
    {
      "car_id": "候选车型的 id",
      "headline": "针对这位用户，这款车的一句话定位",
      "pros": ["对你来说合适的点", "..."],
      "cons": ["你需要注意的点", "..."]
    }
  ],
  "final_advice": "2-3 句最终建议"
}
''';
  }

  /// 从模型返回内容中提取 JSON 对象。
  static Map<String, dynamic> _extractJson(String content) {
    try {
      return jsonDecode(content) as Map<String, dynamic>;
    } on FormatException {
      final start = content.indexOf('{');
      final end = content.lastIndexOf('}');
      if (start >= 0 && end > start) {
        return jsonDecode(content.substring(start, end + 1))
            as Map<String, dynamic>;
      }
      rethrow;
    }
  }

  /// 解析为 AiReport，并校验 / 补全候选车型。
  static AiReport _parseReport(Map<String, dynamic> json, List<Car> cars) {
    final validIds = cars.map((c) => c.id).toSet();
    final rawRanking = (json['ranking'] as List? ?? const [])
        .map((e) => CarVerdict.fromJson(e as Map<String, dynamic>))
        .where((v) => validIds.contains(v.carId))
        .toList();

    final present = rawRanking.map((v) => v.carId).toSet();
    for (final car in cars) {
      if (!present.contains(car.id)) {
        rawRanking.add(
          CarVerdict(
            carId: car.id,
            headline: '',
            pros: car.highlights,
            cons: car.weaknesses,
          ),
        );
      }
    }

    if (rawRanking.isEmpty) {
      throw const FormatException('模型返回的 ranking 为空');
    }

    return AiReport(
      conclusion: (json['conclusion'] as String?) ?? '',
      ranking: rawRanking,
      finalAdvice: (json['final_advice'] as String?) ?? '',
      aiGenerated: true,
    );
  }
}

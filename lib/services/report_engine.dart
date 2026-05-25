import '../models/ai_report.dart';
import '../models/car.dart';
import '../models/survey.dart';

/// 本地报告引擎：对候选车型评分、排序，并在大模型不可用时兜底生成报告。
class ReportEngine {
  /// 关键词表：把用户在意的点映射到车型文案里的可匹配词。
  static const Map<String, List<String>> _priorityKeywords = {
    '智能驾驶': ['智驾', '智能', 'XNGP', 'NGP', '辅助驾驶', 'Pilot'],
    '驾驶质感': ['驾控', '操控', '驾驶乐趣', '运动', '多连杆', '双叉臂'],
    '空间舒适性': ['空间', '舒适', '宽适', '宽裕'],
    '外观设计': ['外观', '造型', '设计', '猎装', '讨喜'],
    '性价比': ['性价比', '亲民', '厚道'],
    '品牌可靠性': ['保值', '保有量', '服务体系', '可靠', '服务'],
    '续航里程': ['续航'],
    '充电速度': ['快充', '超充', '闪充', '800V', '换电', '补能'],
  };

  static const List<String> rankLabels = ['推荐', '备选', '再考虑'];
  static const List<int> rankStars = [5, 4, 3];

  static int scoreCar(UserProfile profile, Car car) {
    var s = 0;
    if (car.segment == profile.budgetSegment) s += 4;
    final hay = [
      ...car.highlights,
      ...car.bestFor,
      car.smartDriving,
      car.fastCharge,
      car.suspension,
    ].join(' ');
    for (final p in profile.priorities) {
      final keywords = _priorityKeywords[p] ?? const [];
      if (keywords.any(hay.contains)) s += 3;
    }
    if (profile.dailyKm.startsWith('100') && car.rangeKm >= 600) s += 2;
    if (profile.charging.startsWith('不能装')) {
      final fc = car.fastCharge;
      if (fc.contains('20 分钟') ||
          fc.contains('15 分钟') ||
          fc.contains('换电') ||
          fc.contains('超充')) {
        s += 2;
      }
    }
    return s;
  }

  /// 按匹配度从高到低排序候选车型。
  static List<Car> rankCars(UserProfile profile, List<Car> cars) {
    final list = [...cars];
    list.sort((a, b) => scoreCar(profile, b) - scoreCar(profile, a));
    return list;
  }

  /// 大模型不可用时的本地兜底报告，结构与 AI 报告一致。
  static AiReport buildLocalReport(UserProfile profile, List<Car> cars) {
    final ranked = rankCars(profile, cars);
    final top = ranked.first;
    final priority =
        profile.priorities.isNotEmpty ? profile.priorities.first : '综合表现';

    return AiReport(
      aiGenerated: false,
      conclusion: '基于你的实际情况，推荐 ${top.name}，'
          '它在你最在意的点上更贴合，价位也在可接受范围内。',
      finalAdvice: '你最在意「$priority」，结合${profile.scenario}的使用场景，'
          '${top.name} 是目前候选里更稳妥的选择。'
          '建议到店实际试驾后再做最终决定，重点体验你最在意的部分。',
      ranking: [
        for (var i = 0; i < ranked.length; i++)
          CarVerdict(
            carId: ranked[i].id,
            headline: _localHeadline(profile, ranked[i], i == 0),
            pros: ranked[i].highlights,
            cons: ranked[i].weaknesses,
          ),
      ],
    );
  }

  static String _localHeadline(UserProfile profile, Car car, bool isTop) {
    final budgetFit = car.segment == profile.budgetSegment;
    if (isTop) {
      return '价位落在你的「${profile.budget}」预算${budgetFit ? '区间内' : '附近'}，'
          '在你最在意的点上表现也更突出。';
    }
    return budgetFit
        ? '同样符合你的预算，适合作为备选一起对比。'
        : '价位与你的「${profile.budget}」预算有一定偏差，需要再权衡。';
  }
}

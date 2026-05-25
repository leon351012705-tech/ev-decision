/// 引导问卷中的一道题。
class SurveyQuestion {
  final String id;
  final String title;
  final String? hint;
  final List<String> options;
  final bool multi;
  final int maxSelect;

  const SurveyQuestion({
    required this.id,
    required this.title,
    required this.options,
    this.hint,
    this.multi = false,
    this.maxSelect = 1,
  });
}

/// PRD 第四节定义的 5 个核心问题。
const List<SurveyQuestion> kSurveyQuestions = [
  SurveyQuestion(
    id: 'scenario',
    title: '你主要的用车场景是？',
    options: ['城市通勤为主', '跨城出差较多', '家庭出游为主', '多种场景混合'],
  ),
  SurveyQuestion(
    id: 'daily_km',
    title: '日均行驶里程？',
    options: ['30 km 以下', '30-60 km', '60-100 km', '100 km 以上'],
  ),
  SurveyQuestion(
    id: 'charging',
    title: '家里能装充电桩吗？',
    options: ['能装（私桩条件好）', '不能装（只能用公桩）', '不确定'],
  ),
  SurveyQuestion(
    id: 'budget',
    title: '预算区间？',
    options: ['8 万以下', '8-15 万', '15-25 万', '25 万以上'],
  ),
  SurveyQuestion(
    id: 'priorities',
    title: '你最在意什么？',
    hint: '多选，最多 3 项',
    options: [
      '智能驾驶',
      '驾驶质感',
      '空间舒适性',
      '外观设计',
      '性价比',
      '品牌可靠性',
      '续航里程',
      '充电速度',
    ],
    multi: true,
    maxSelect: 3,
  ),
];

/// 用户画像 —— 5 道题的结构化答案。
class UserProfile {
  final String scenario;
  final String dailyKm;
  final String charging;
  final String budget;
  final List<String> priorities;

  const UserProfile({
    required this.scenario,
    required this.dailyKm,
    required this.charging,
    required this.budget,
    required this.priorities,
  });

  factory UserProfile.fromAnswers(Map<String, dynamic> a) => UserProfile(
        scenario: a['scenario'] as String,
        dailyKm: a['daily_km'] as String,
        charging: a['charging'] as String,
        budget: a['budget'] as String,
        priorities: List<String>.from(a['priorities'] as List? ?? const []),
      );

  Map<String, dynamic> toJson() => {
        'scenario': scenario,
        'daily_km': dailyKm,
        'charging': charging,
        'budget': budget,
        'priorities': priorities,
      };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        scenario: j['scenario'] as String,
        dailyKm: j['daily_km'] as String,
        charging: j['charging'] as String,
        budget: j['budget'] as String,
        priorities: List<String>.from(j['priorities'] as List? ?? const []),
      );

  /// 预算档对应的车型价格段，用于本地规则匹配。
  String get budgetSegment {
    if (budget.startsWith('8 万以下') || budget.startsWith('8-15')) {
      return '经济段';
    }
    if (budget.startsWith('15-25')) return '主流段';
    return '中高端';
  }
}

# 电动车决策助手 PRD

## 一、项目背景

**一句话定位**：一个基于 AI 的电动车购买决策助手，帮用户在 BYD、小鹏等候选车型之间做出适合自己的选择。

**真实故事**：开发者本人过去三个月在比亚迪海豹 06 GT 和小鹏 MONA M03 之间纠结，意识到电动车选购是普遍痛点——参数对比工具一大堆，但没人告诉用户"对你来说哪个更合适"。这个 App 解决的就是这个最后一公里。

**项目目标**：用 Vibe Coding 模式（Cursor + Flutter + LLM API）在两天内完成从需求到上线的全流程，作为 AI 产品工程师岗位的能力证明。

## 二、目标用户

**核心画像**：

- 年龄 25-40 岁，准备购买人生第一台/第二台车
- 关注电动车但被海量信息淹没
- 看过测评但越看越纠结
- 希望有一个能基于自己实际情况给出建议的工具

**典型场景**：

- 周末在家研究购车，参数对比 30 分钟头大
- 看完懂车帝/汽车之家依然拿不定主意
- 想要"有人帮我下决心"的那种工具

## 三、核心功能（MVP）

**主流程**（必做）：

```
启动 → 引导问卷(5题) → 选择 2-3 款候选车 → AI 生成决策报告 → 保存历史
```

**功能清单**：

| 编号 | 功能 | 优先级 | 说明 |
|------|------|--------|------|
| F1 | 欢迎页 | P0 | Logo + Slogan + "开始评估"按钮 |
| F2 | 用户画像问卷 | P0 | 5 个核心问题，引导式 UI |
| F3 | 候选车型选择页 | P0 | 从 15 款预置车型中选 2-3 款 |
| F4 | AI 决策报告页 | P0 | 调用 LLM API 生成个性化报告 |
| F5 | 历史记录页 | P1 | 本地 SQLite 存储过往评估记录 |
| F6 | 关于页 | P2 | 项目说明、开发者信息、GitHub 链接 |

**不做**（明确砍掉）：

- ❌ 实时电价 API 接入
- ❌ 全网车型库爬虫
- ❌ 用户登录系统
- ❌ 云端同步
- ❌ 多模态拍照识车
- ❌ 分享到社交平台
- ❌ 充电桩地图
- ❌ 二手车信息

## 四、5 个核心问题设计

**Q1：你主要的用车场景是？**
- 城市通勤为主
- 跨城出差较多
- 家庭出游为主
- 多种场景混合

**Q2：日均行驶里程？**
- 30 km 以下
- 30-60 km
- 60-100 km
- 100 km 以上

**Q3：家里能装充电桩吗？**
- 能装（私桩条件好）
- 不能装（只能用公桩）
- 不确定

**Q4：预算区间？**
- 8 万以下
- 8-15 万
- 15-25 万
- 25 万以上

**Q5：你最在意什么？**（多选，最多 3 项）
- 智能驾驶
- 驾驶质感
- 空间舒适性
- 外观设计
- 性价比
- 品牌可靠性
- 续航里程
- 充电速度

## 五、候选车型数据（15 款）

预置在本地 `assets/cars.json` 文件里，覆盖三个价格段：

**8-15 万经济段**：

1. 比亚迪海鸥
2. 比亚迪海豚
3. 比亚迪秦 PLUS EV
4. 小鹏 MONA M03
5. 五菱缤果

**15-25 万主流段**：

6. 比亚迪海豹 06 GT
7. 比亚迪宋 PLUS EV
8. 小鹏 P5
9. 小鹏 G6
10. 零跑 C11

**25 万以上中高端**：

11. 特斯拉 Model 3
12. 比亚迪汉 EV
13. 小鹏 P7+
14. 蔚来 ET5
15. 极氪 001

每款车的数据字段（示例）：

```json
{
  "id": "byd_seal_06gt",
  "name": "比亚迪海豹 06 GT",
  "brand": "BYD",
  "price_range": "12-15万",
  "segment": "主流段",
  "price_min": 119800,
  "price_max": 149800,
  "category": "紧凑型轿跑",
  "battery_capacity": "65 kWh",
  "range_km": 545,
  "fast_charge": "30%-80% 约 20 分钟",
  "suspension": "前麦弗逊 + 后多连杆",
  "smart_driving": "DiPilot 100,基础辅助驾驶",
  "highlights": ["驾控扎实", "多连杆后悬", "闪充", "运动设计"],
  "weaknesses": ["智驾相对一般", "后排空间紧凑"],
  "best_for": ["驾驶乐趣党", "外观党", "通勤为主"]
}
```

## 六、AI 报告生成

**输入**：
- 用户画像（5 题答案的结构化数据）
- 候选车型数据（2-3 款车的完整 JSON）

**输出**：见 [prompt-design.md](./prompt-design.md) —— 实际实现从 PRD 原方案的 Markdown 改成了结构化 JSON，套进 App 的卡片布局渲染，理由详见该文档。

## 七、技术栈

- **开发语言**：Dart
- **框架**：Flutter（跨端，先出 Android 版）
- **状态管理**：Provider（简单够用）
- **本地存储**：sqflite（SQLite）
- **HTTP 请求**：dio
- **LLM API**：智谱 GLM-4-Flash（免费、国内直连，PRD 原方案为 DeepSeek）
- **开发工具**：Cursor + Claude Code + Android Studio
- **设备**：Windows + Android Studio 模拟器
- **代码托管**：GitHub
- **包名**：`com.leon.evdecision`

## 八、页面流转和信息架构

```
[欢迎页 HomeTab]
       ↓ 点击"开始评估"
[问卷页 SurveyScreen]
       ↓ 5 题答完
[选车页 CarSelectScreen]
       ↓ 选 2-3 款
[加载页 LoadingScreen] (调用 LLM API,显示动画)
       ↓ API 返回 / 本地兜底
[报告页 ReportScreen]
       ↓ 已自动保存
[历史记录页 HistoryScreen] (从底部 tab 进入)
```

底部导航栏：[首页] [历史] [关于]

## 九、UI 设计原则

- **整体风格**：苹果式黑白极简（参考 Linear / Notion / iOS Settings）
- **主色调**：黑 `#1D1D1F` + 浅灰背景 `#F5F5F7` + 白卡片
- **字体**：系统默认中文字体
- **核心交互**：单页一焦点，避免信息过载
- **报告页**：用结构化卡片渲染（黑色结论卡 / 星级 / ✓ ! 分析），关键信息高对比

## 十、数据存储设计

**evaluations 表**（评估记录）：

```sql
CREATE TABLE evaluations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  created_at TEXT NOT NULL,
  user_profile TEXT NOT NULL,      -- JSON：5 题答案
  selected_cars TEXT NOT NULL,     -- JSON 数组：候选车 id
  report_markdown TEXT NOT NULL,   -- JSON：AiReport 序列化（沿用 PRD 字段名）
  recommended_car_id TEXT          -- 推荐车型 id
);
```

> 实际实现中，`report_markdown` 字段存的是结构化 `AiReport` 的 JSON 序列化，而非 Markdown 文本——见 prompt-design.md 的格式决策。字段名保留 PRD 原 schema。

## 十一、两天施工计划

**Day 1**：
- 上午：环境验证 + Flutter 项目初始化 + 三页骨架（mock 数据跑通流程）
- 下午：问卷页 + 选车页完整实现 + 数据流打通
- 晚上：cars.json + UI 第一轮调优

**Day 2**：
- 上午：接入 LLM API + 报告页 + 结构化渲染
- 下午：历史记录 + SQLite + 底部导航
- 晚上：UI 第二轮调优 + 录演示视频 + 写 README + 推 GitHub + 打 Release APK

## 十二、交付物清单

- [x] GitHub 仓库（公开，含完整代码）
- [x] README.md（项目说明、技术栈、Vibe Coding 实录、截图、演示视频链接）
- [x] docs/PRD.md
- [x] docs/prompt-design.md
- [ ] Release APK 文件
- [ ] 演示视频（90 秒）
- [ ] 4-6 张产品截图

## 十三、面试演示策略

**90 秒演示视频脚本**：

- 0-15s：开场——讲真实故事，"过去三个月我在 BYD 海豹 06 GT 和小鹏 MONA M03 之间纠结……"
- 15-50s：现场操作 App——答 5 题 → 选两台车 → 生成报告
- 50-75s：展示报告——指出"它告诉我基于我的实际场景该选哪台、为什么"
- 75-90s：总结——"用 Cursor + Claude Code 在 48 小时内独立完成，技术栈 Flutter + LLM API，代码开源在 GitHub。"

## 十四、风险和应对

| 风险 | 应对 |
|------|------|
| Flutter 环境配置卡住 | 预留 Day 1 上午的 3h buffer |
| LLM API 返回不稳定 | 本地规则引擎自动兜底，banner 明示 |
| 模拟器性能不够 | 关闭其他程序，必要时换轻量模拟器 |
| UI 做得丑 | 采用极简设计，不追求酷炫 |
| 两天做不完 | 优先级砍 P2 功能，报告页质量优先 |

## 十五、隐藏加分点

- 技术博客记录 Vibe Coding 全流程
- 有辨识度的 App 图标
- 配套官网展示 App 和下载 APK
- 用户量到百万级的架构演进思考

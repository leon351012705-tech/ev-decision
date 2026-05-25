/// 大模型接入配置 —— 模板文件。
///
/// 使用方法：把本文件复制为同目录下的 `llm_config.dart`，
/// 再把 apiKey 换成你自己的智谱开放平台 Key。
/// `llm_config.dart` 已加入 .gitignore，不会被提交。
///
/// 申请地址：https://open.bigmodel.cn  → 控制台 → API Keys
class LlmConfig {
  /// 智谱开放平台 API Key。留空时 App 自动走本地兜底引擎。
  static const String apiKey = '';

  /// 智谱开放平台 OpenAI 兼容 chat/completions 接口。
  static const String baseUrl =
      'https://open.bigmodel.cn/api/paas/v4/chat/completions';

  /// 模型名。glm-4-flash 为免费模型。
  static const String model = 'glm-4-flash';
}

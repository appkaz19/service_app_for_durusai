class AppConfig {
  static const String appName = 'DURUSAI';
  static const String appTagline = 'AI-Powered Voice & Video Generation';
  static const String appDescription =
      'Transform any face into a talking avatar with advanced AI technology';

  static const String baseUrl = 'http://localhost:8000';
  static const String apiKey = '';

  static const bool enable3DRobot = true;
  static const bool enableInteractiveRobot = true;
  static const bool enableRobotAnimations = true;

  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration pollInterval = Duration(seconds: 2);

  static const int maxImageSizeMB = 10;
  static const int maxAudioSizeMB = 50;

  static const Map<String, String> supportedLanguages = {
    'en-US': 'en',
    'en-GB': 'en',
    'ru-RU': 'ru',
    'es-ES': 'es',
    'de-DE': 'de',
    'fr-FR': 'fr',
    'kk-KZ': 'ru',
    'uz-UZ': 'ru',
  };

  static const bool enableVoiceCloning = true;
  static const bool enableBulkGeneration = false;
  static const bool enableAnalytics = false;

  static const int robotPrimaryColor = 0x667eea;
  static const int robotSecondaryColor = 0x764ba2;
  static const int robotEyeColor = 0x00ffff;
}

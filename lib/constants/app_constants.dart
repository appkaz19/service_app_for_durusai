class AppConstants {
  // App Info
  static const String appName = 'AI Content Generator';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String apiBaseUrl =
      'http://localhost:8000'; // Замените на ваш URL backend
  static const String? apiKey = null; // Добавьте ключ API если требуется

  // File Upload
  static const int maxFileSize = 100 * 1024 * 1024; // 100 MB
  static const List<String> allowedFileTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
    'video/mp4',
    'video/mpeg',
    'audio/mpeg',
    'audio/wav',
    'audio/mp3',
    'application/pdf',
    'text/plain',
  ];

  // Generation Options
  static const List<String> outputFormats = [
    'Text',
    'Voice',
    'Video',
    'Music',
  ];

  // Languages
  static const List<String> supportedLanguages = [
    'Русский',
    'English',
    'Español',
    'Deutsch',
    'Français',
    'Türkçe',
    'العربية',
    'हिन्दी',
    '中文',
    '日本語',
    '한국어',
    'Italiano',
    'Português',
    'Polski',
    'Қазақша',
    'O\'zbekcha',
  ];

  // Video Generation Languages (subset supported by backend)
  static const Map<String, String> videoLanguages = {
    'ru': 'Русский',
    'en': 'English',
    'es': 'Español',
    'de': 'Deutsch',
    'fr': 'Français',
  };

  // Voice Types
  static const List<String> voiceTypes = [
    'Natural',
    'Professional',
    'Friendly',
    'Energetic',
    'Calm',
    'Authoritative',
  ];

  // Video Styles
  static const List<String> videoStyles = [
    'Realistic',
    'Animated',
    'Minimalist',
    'Corporate',
    'Creative',
    'Educational',
  ];

  // Video Quality Options
  static const List<String> videoQualities = [
    'Standard (480p)',
    'HD (720p)',
    'Full HD (1080p)',
    '4K (2160p)',
  ];

  // Music Genres
  static const List<String> musicGenres = [
    'Ambient',
    'Classical',
    'Electronic',
    'Jazz',
    'Pop',
    'Rock',
    'Hip Hop',
    'World',
  ];

  // UI Constants
  static const double maxContentWidth = 1200;
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;

  // Animation Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);

  // Error Messages
  static const String networkError = 'Проверьте подключение к интернету';
  static const String serverError = 'Ошибка сервера. Попробуйте позже';
  static const String unknownError = 'Произошла неизвестная ошибка';
  static const String fileTooLarge = 'Файл слишком большой. Максимум 100 МБ';
  static const String unsupportedFileType = 'Неподдерживаемый тип файла';

  // Success Messages
  static const String uploadSuccess = 'Файл успешно загружен';
  static const String generationStarted = 'Генерация началась';
  static const String generationComplete = 'Генерация завершена';

  // Task Status Messages
  static const Map<String, String> taskStatusMessages = {
    'pending': 'Ожидание обработки...',
    'processing': 'Обработка...',
    'generating': 'Генерация контента...',
    'completed': 'Готово!',
    'failed': 'Ошибка при обработке',
  };
}

import 'dart:io';

class GenerationOptions {
  // General options
  final String language;
  final String outputFormat;
  final String? textInput;

  // Voice generation options
  final bool generateVoice;
  final String voiceType;
  final double speechSpeed;
  final double pitch;

  // Video generation options
  final bool generateVideo;
  final String? videoLanguage;
  final String videoStyle;
  final String videoQuality;
  final File? speakerAudioFile;
  final bool enableLipSync;
  final bool enableVoiceConversion;

  // Music generation options
  final bool generateMusic;
  final String musicGenre;
  final int musicDuration; // in seconds
  final String mood;

  // Text generation options
  final bool generateText;
  final int maxTextLength;
  final double creativity; // 0.0 to 1.0

  // Advanced options
  final bool useGPU;
  final int priority; // 1 (low) to 10 (high)
  final bool saveToCloud;
  final String? webhookUrl;

  GenerationOptions({
    this.language = 'Русский',
    this.outputFormat = 'Video',
    this.textInput,
    // Voice
    this.generateVoice = true,
    this.voiceType = 'Natural',
    this.speechSpeed = 1.0,
    this.pitch = 1.0,
    // Video
    this.generateVideo = false,
    this.videoLanguage = 'ru',
    this.videoStyle = 'Realistic',
    this.videoQuality = 'HD (720p)',
    this.speakerAudioFile,
    this.enableLipSync = true,
    this.enableVoiceConversion = false,
    // Music
    this.generateMusic = false,
    this.musicGenre = 'Ambient',
    this.musicDuration = 60,
    this.mood = 'Neutral',
    // Text
    this.generateText = false,
    this.maxTextLength = 500,
    this.creativity = 0.7,
    // Advanced
    this.useGPU = true,
    this.priority = 5,
    this.saveToCloud = true,
    this.webhookUrl,
  });

  // Copy with method for updating options
  GenerationOptions copyWith({
    String? language,
    String? outputFormat,
    String? textInput,
    bool? generateVoice,
    String? voiceType,
    double? speechSpeed,
    double? pitch,
    bool? generateVideo,
    String? videoLanguage,
    String? videoStyle,
    String? videoQuality,
    File? speakerAudioFile,
    bool? enableLipSync,
    bool? enableVoiceConversion,
    bool? generateMusic,
    String? musicGenre,
    int? musicDuration,
    String? mood,
    bool? generateText,
    int? maxTextLength,
    double? creativity,
    bool? useGPU,
    int? priority,
    bool? saveToCloud,
    String? webhookUrl,
  }) {
    return GenerationOptions(
      language: language ?? this.language,
      outputFormat: outputFormat ?? this.outputFormat,
      textInput: textInput ?? this.textInput,
      generateVoice: generateVoice ?? this.generateVoice,
      voiceType: voiceType ?? this.voiceType,
      speechSpeed: speechSpeed ?? this.speechSpeed,
      pitch: pitch ?? this.pitch,
      generateVideo: generateVideo ?? this.generateVideo,
      videoLanguage: videoLanguage ?? this.videoLanguage,
      videoStyle: videoStyle ?? this.videoStyle,
      videoQuality: videoQuality ?? this.videoQuality,
      speakerAudioFile: speakerAudioFile ?? this.speakerAudioFile,
      enableLipSync: enableLipSync ?? this.enableLipSync,
      enableVoiceConversion:
          enableVoiceConversion ?? this.enableVoiceConversion,
      generateMusic: generateMusic ?? this.generateMusic,
      musicGenre: musicGenre ?? this.musicGenre,
      musicDuration: musicDuration ?? this.musicDuration,
      mood: mood ?? this.mood,
      generateText: generateText ?? this.generateText,
      maxTextLength: maxTextLength ?? this.maxTextLength,
      creativity: creativity ?? this.creativity,
      useGPU: useGPU ?? this.useGPU,
      priority: priority ?? this.priority,
      saveToCloud: saveToCloud ?? this.saveToCloud,
      webhookUrl: webhookUrl ?? this.webhookUrl,
    );
  }

  // Convert video language code to backend format
  String get backendVideoLanguage {
    final langMap = {
      'Русский': 'ru',
      'English': 'en',
      'Español': 'es',
      'Deutsch': 'de',
      'Français': 'fr',
    };
    return langMap[language] ?? videoLanguage ?? 'ru';
  }

  // Check if video generation is possible
  bool get canGenerateVideo {
    return generateVideo && (outputFormat == 'Video' || outputFormat == 'All');
  }

  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'output_format': outputFormat,
      'text_input': textInput,
      'voice_options': {
        'enabled': generateVoice,
        'type': voiceType,
        'speed': speechSpeed,
        'pitch': pitch,
      },
      'video_options': {
        'enabled': generateVideo,
        'language': backendVideoLanguage,
        'style': videoStyle,
        'quality': videoQuality,
        'lip_sync': enableLipSync,
        'voice_conversion': enableVoiceConversion,
      },
      'music_options': {
        'enabled': generateMusic,
        'genre': musicGenre,
        'duration': musicDuration,
        'mood': mood,
      },
      'text_options': {
        'enabled': generateText,
        'max_length': maxTextLength,
        'creativity': creativity,
      },
      'advanced': {
        'use_gpu': useGPU,
        'priority': priority,
        'save_to_cloud': saveToCloud,
        'webhook_url': webhookUrl,
      },
    };
  }
}

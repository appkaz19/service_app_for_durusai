class GenerationOptions {
  final String language;
  final String quality;
  final String style;
  final String duration;
  final String outputType;

  const GenerationOptions({
    required this.language,
    required this.quality,
    required this.style,
    required this.duration,
    required this.outputType,
  });

  GenerationOptions copyWith({
    String? language,
    String? quality,
    String? style,
    String? duration,
    String? outputType,
  }) {
    return GenerationOptions(
      language: language ?? this.language,
      quality: quality ?? this.quality,
      style: style ?? this.style,
      duration: duration ?? this.duration,
      outputType: outputType ?? this.outputType,
    );
  }
}

import '../services/api_service.dart';

class GenerationResponse {
  final String taskId;
  final String status;

  GenerationResponse({
    required this.taskId,
    required this.status,
  });

  factory GenerationResponse.fromJson(Map<String, dynamic> json) {
    return GenerationResponse(
      taskId: json['task_id'] ?? '',
      status: json['status'] ?? 'PENDING',
    );
  }
}

class TaskResult {
  final String taskId;
  final String status;
  final String? videoUrl;
  final String? audioUrl;
  final String? error;
  final Map<String, dynamic>? metadata;

  TaskResult({
    required this.taskId,
    required this.status,
    this.videoUrl,
    this.audioUrl,
    this.error,
    this.metadata,
  });

  factory TaskResult.fromJson(Map<String, dynamic> json) {
    return TaskResult(
      taskId: json['task_id'] ?? '',
      status: json['status'] ?? 'PENDING',
      videoUrl: json['video_url'],
      audioUrl: json['audio_url'],
      error: json['error'],
      metadata: json['metadata'],
    );
  }

  bool get isCompleted => status == ApiService.statusSuccess;
  bool get isFailed => status == ApiService.statusFailure;
  bool get isProcessing =>
      status == ApiService.statusProcessing ||
      status == ApiService.statusPending;
}

class ApiException implements Exception {
  final String message;
  final String details;

  ApiException(this.message, this.details);

  @override
  String toString() => 'ApiException: $message\nDetails: $details';
}

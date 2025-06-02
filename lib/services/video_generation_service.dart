import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../constants/app_constants.dart';
import '../models/generation_options.dart';

class VideoGenerationService {
  final String baseUrl;
  final String? apiKey;
  final http.Client _client;
  
  VideoGenerationService({
    String? baseUrl,
    String? apiKey,
    http.Client? client,
  }) : this.baseUrl = baseUrl ?? AppConstants.apiBaseUrl,
       this.apiKey = apiKey ?? AppConstants.apiKey,
       this._client = client ?? http.Client();

  // Generate video with face animation
  Future<String> generateVideo({
    required File imageFile,
    required String text,
    required String language,
    File? speakerAudio,
    GenerationOptions? options,
  }) async {
    final uri = Uri.parse('$baseUrl/generate');
    
    final request = http.MultipartRequest('POST', uri);
    
    // Add API key if exists
    if (apiKey != null) {
      request.headers['X-API-Key'] = apiKey!;
    }
    
    // Add image file
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: path.basename(imageFile.path),
      ),
    );
    
    // Add text and language
    request.fields['text'] = text;
    request.fields['language'] = language;
    
    // Add speaker audio if provided
    if (speakerAudio != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'speaker_audio',
          speakerAudio.path,
          filename: path.basename(speakerAudio.path),
        ),
      );
    }
    
    // Add additional options if provided
    if (options != null) {
      request.fields['enable_lip_sync'] = options.enableLipSync.toString();
      request.fields['enable_voice_conversion'] = options.enableVoiceConversion.toString();
      request.fields['video_quality'] = options.videoQuality;
      request.fields['priority'] = options.priority.toString();
    }
    
    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return data['task_id'];
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid API key');
      } else if (response.statusCode == 400) {
        final error = json.decode(responseBody);
        throw ValidationException(error['detail'] ?? 'Invalid request');
      } else {
        throw ApiException('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
    }
  }
  
  // Check task status
  Future<TaskResult> checkTaskStatus(String taskId) async {
    final uri = Uri.parse('$baseUrl/result/$taskId');
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (apiKey != null) {
      headers['X-API-Key'] = apiKey!;
    }
    
    try {
      final response = await _client.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TaskResult.fromJson(data);
      } else if (response.statusCode == 404) {
        throw TaskNotFoundException('Task not found: $taskId');
      } else {
        throw ApiException('Failed to check status: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
    }
  }
  
  // Stream task status updates
  Stream<TaskResult> waitForCompletion(
    String taskId, {
    Duration checkInterval = const Duration(seconds: 2),
    Duration timeout = const Duration(minutes: 10),
  }) async* {
    final startTime = DateTime.now();
    
    while (true) {
      try {
        final result = await checkTaskStatus(taskId);
        yield result;
        
        if (result.isCompleted || result.isFailed) {
          break;
        }
        
        // Check timeout
        if (DateTime.now().difference(startTime) > timeout) {
          throw TimeoutException('Task timed out after ${timeout.inMinutes} minutes');
        }
        
        await Future.delayed(checkInterval);
      } catch (e) {
        yield TaskResult(
          status: 'error',
          error: e.toString(),
        );
        break;
      }
    }
  }
  
  // Cancel task
  Future<bool> cancelTask(String taskId) async {
    final uri = Uri.parse('$baseUrl/cancel/$taskId');
    
    final headers = <String, String>{};
    if (apiKey != null) {
      headers['X-API-Key'] = apiKey!;
    }
    
    try {
      final response = await _client.post(uri, headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // Get all tasks for current API key
  Future<List<TaskInfo>> getTasks({
    int limit = 10,
    int offset = 0,
  }) async {
    final uri = Uri.parse('$baseUrl/tasks?limit=$limit&offset=$offset');
    
    final headers = <String, String>{};
    if (apiKey != null) {
      headers['X-API-Key'] = apiKey!;
    }
    
    try {
      final response = await _client.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => TaskInfo.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to get tasks: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
    }
  }
  
  void dispose() {
    _client.close();
  }
}

// Data models
class TaskResult {
  final String status;
  final String? videoPath;
  final String? error;
  final Map<String, dynamic>? metadata;
  
  TaskResult({
    required this.status,
    this.videoPath,
    this.error,
    this.metadata,
  });
  
  factory TaskResult.fromJson(Map<String, dynamic> json) {
    return TaskResult(
      status: json['status'],
      videoPath: json['video_path'],
      error: json['error'],
      metadata: json['metadata'],
    );
  }
  
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isProcessing => !isCompleted && !isFailed;
  
  String get displayStatus {
    return AppConstants.taskStatusMessages[status] ?? status;
  }
}

class TaskInfo {
  final String id;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? videoUrl;
  final Map<String, dynamic>? params;
  
  TaskInfo({
    required this.id,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.videoUrl,
    this.params,
  });
  
  factory TaskInfo.fromJson(Map<String, dynamic> json) {
    return TaskInfo(
      id: json['id'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      videoUrl: json['video_url'],
      params: json['params'],
    );
  }
}

// Custom exceptions
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message);
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message);
}

class TaskNotFoundException extends ApiException {
  TaskNotFoundException(String message) : super(message);
}

class TimeoutException extends ApiException {
  TimeoutException(String message) : super(message);
}
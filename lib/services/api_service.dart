import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/api_models.dart';

class ApiService {
  static const String statusPending = 'PENDING';
  static const String statusProcessing = 'PROCESSING';
  static const String statusSuccess = 'SUCCESS';
  static const String statusFailure = 'FAILURE';

  static Future<GenerationResponse> generateContent({
    required Uint8List? imageBytes,
    required String text,
    required String language,
    Uint8List? speakerAudioBytes,
    String? imageFileName,
    String? audioFileName,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/generate');
      final request = http.MultipartRequest('POST', uri);

      if (AppConfig.apiKey.isNotEmpty) {
        request.headers['X-API-Key'] = AppConfig.apiKey;
      }

      request.fields['text'] = text;
      request.fields['language'] = language;

      if (imageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: imageFileName ?? 'image.jpg',
          ),
        );
      }

      if (speakerAudioBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'speaker_audio',
            speakerAudioBytes,
            filename: audioFileName ?? 'speaker.wav',
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return GenerationResponse.fromJson(data);
      } else {
        throw ApiException('Failed to generate content: ${response.statusCode}', responseBody);
      }
    } catch (e) {
      throw ApiException('Network error', e.toString());
    }
  }

  static Future<TaskResult> getTaskResult(String taskId) async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/result/$taskId');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (AppConfig.apiKey.isNotEmpty) {
        headers['X-API-Key'] = AppConfig.apiKey;
      }

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TaskResult.fromJson(data);
      } else {
        throw ApiException('Failed to get task result: ${response.statusCode}', response.body);
      }
    } catch (e) {
      throw ApiException('Network error', e.toString());
    }
  }

  static Stream<TaskResult> pollTaskResult(String taskId, {Duration interval = const Duration(seconds: 2)}) async* {
    while (true) {
      try {
        final result = await getTaskResult(taskId);
        yield result;
        
        if (result.status == statusSuccess || result.status == statusFailure) {
          break;
        }
        
        await Future.delayed(interval);
      } catch (e) {
        yield TaskResult(
          taskId: taskId,
          status: statusFailure,
          error: e.toString(),
        );
        break;
      }
    }
  }

  static String convertLanguageCode(String flutterLanguageCode) {
    return AppConfig.supportedLanguages[flutterLanguageCode] ?? 'en';
  }
}
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../config/app_config.dart';

enum CustomFileType { image, audio, video, document, unknown }

class SelectedFile {
  final String name;
  final int size;
  final Uint8List bytes;
  final String extension;
  final CustomFileType type;

  SelectedFile({
    required this.name,
    required this.size,
    required this.bytes,
    required this.extension,
    required this.type,
  });

  String get formattedSize {
    final sizeInMB = size / 1024 / 1024;
    return '${sizeInMB.toStringAsFixed(2)} MB';
  }

  String get icon {
    switch (type) {
      case CustomFileType.image:
        return '🖼️';
      case CustomFileType.audio:
        return '🎵';
      case CustomFileType.video:
        return '🎬';
      case CustomFileType.document:
        return '📄';
      case CustomFileType.unknown:
      default:
        return '📁';
    }
  }
}

class FileService {
  static Future<SelectedFile?> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (file.bytes != null) {
          return SelectedFile(
            name: file.name,
            size: file.size,
            bytes: file.bytes!,
            extension: file.extension ?? '',
            type: _getFileType(file.extension),
          );
        }
      }
      return null;
    } catch (e) {
      throw FileException('Failed to pick file: $e');
    }
  }

  static CustomFileType _getFileType(String? extension) {
    if (extension == null) return CustomFileType.unknown;

    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return CustomFileType.image;
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'flac':
        return CustomFileType.audio;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'mkv':
        return CustomFileType.video;
      case 'pdf':
      case 'doc':
      case 'docx':
      case 'txt':
        return CustomFileType.document;
      default:
        return CustomFileType.unknown;
    }
  }

  static bool isValidImageFile(SelectedFile file) {
    return file.type == CustomFileType.image &&
        file.size <= AppConfig.maxImageSizeMB * 1024 * 1024;
  }

  static bool isValidAudioFile(SelectedFile file) {
    return file.type == CustomFileType.audio &&
        file.size <= AppConfig.maxAudioSizeMB * 1024 * 1024;
  }
}

class FileException implements Exception {
  final String message;
  FileException(this.message);

  @override
  String toString() => 'FileException: $message';
}

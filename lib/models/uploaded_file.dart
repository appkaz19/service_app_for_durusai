import 'dart:typed_data';

class UploadedFile {
  final String name;
  final int size;
  final String type;
  final String extension;
  final String? path;        // Добавлено как поле класса
  final Uint8List? bytes;    // Добавлено как поле класса
  
  const UploadedFile({
    required this.name,
    required this.size,
    required this.type,
    required this.extension,
    this.path,              // Теперь это сохраняется
    this.bytes,             // Теперь это сохраняется
  });
  
  String get formattedSize {
    final sizeInMB = size / 1024 / 1024;
    return '${sizeInMB.toStringAsFixed(2)} MB';
  }
  
  String get icon {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return '🖼️';
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'flac':
        return '🎵';
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'mkv':
        return '🎬';
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
      case 'txt':
        return '📝';
      default:
        return '📁';
    }
  }
  
  // Дополнительные полезные геттеры
  bool get isImage => ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension.toLowerCase());
  bool get isVideo => ['mp4', 'avi', 'mov', 'mkv'].contains(extension.toLowerCase());
  bool get isAudio => ['mp3', 'wav', 'aac', 'flac'].contains(extension.toLowerCase());
  bool get isPdf => extension.toLowerCase() == 'pdf';
  bool get isDocument => ['doc', 'docx', 'txt', 'pdf'].contains(extension.toLowerCase());
}
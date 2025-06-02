class UploadedFile {
  final String name;
  final int size;
  final String type;
  final String extension;

  const UploadedFile({
    required this.name,
    required this.size,
    required this.type,
    required this.extension,
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
}
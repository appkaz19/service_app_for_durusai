import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/generation_options.dart';

class VideoOptionsCard extends StatefulWidget {
  final Function(GenerationOptions) onOptionsChanged;
  final GenerationOptions currentOptions;

  const VideoOptionsCard({
    super.key,
    required this.onOptionsChanged,
    required this.currentOptions,
  });

  @override
  State<VideoOptionsCard> createState() => _VideoOptionsCardState();
}

class _VideoOptionsCardState extends State<VideoOptionsCard> {
  late String _selectedLanguage;
  late bool _isVideoEnabled;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.currentOptions.videoLanguage ?? 'ru';
    _isVideoEnabled = widget.currentOptions.generateVideo;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.videocam, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Генерация видео',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Switch(
                  value: _isVideoEnabled,
                  onChanged: (value) {
                    setState(() {
                      _isVideoEnabled = value;
                    });
                    _updateOptions();
                  },
                ),
              ],
            ),
            if (_isVideoEnabled) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: const InputDecoration(
                  labelText: 'Язык озвучки',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.language),
                ),
                items: AppConstants.videoLanguages.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  _updateOptions();
                },
              ),
              const SizedBox(height: 12),
              Text(
                'Для создания видео необходимо загрузить фото лица',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _updateOptions() {
    widget.onOptionsChanged(
      GenerationOptions(
        generateVideo: _isVideoEnabled,
        videoLanguage: _selectedLanguage,
      ),
    );
  }
}

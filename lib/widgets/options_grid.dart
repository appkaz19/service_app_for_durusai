import 'package:flutter/material.dart';
import '../models/generation_options.dart';
import '../utils/responsive_helper.dart';
import '../constants/app_constants.dart';

class OptionsGrid extends StatelessWidget {
  final GenerationOptions options;
  final Function(GenerationOptions) onOptionsChanged;
  
  const OptionsGrid({
    Key? key,
    required this.options,
    required this.onOptionsChanged,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Настройки генерации',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 16),
        
        // Язык
        _buildOptionCard(
          context: context,
          title: 'Язык',
          icon: Icons.language,
          child: DropdownButton<String>(
            value: options.language,
            isExpanded: true,
            items: AppConstants.supportedLanguages.map((lang) {
              return DropdownMenuItem(
                value: lang,
                child: Text(lang),
              );
            }).toList(),
            onChanged: (value) {
              onOptionsChanged(options.copyWith(language: value));
            },
          ),
        ),
        
        SizedBox(height: 16),
        
        // Качество видео
        _buildOptionCard(
          context: context,
          title: 'Качество видео',
          icon: Icons.high_quality,
          child: DropdownButton<String>(
            value: options.videoQuality,
            isExpanded: true,
            items: AppConstants.videoQualities.map((quality) {
              return DropdownMenuItem(
                value: quality,
                child: Text(quality),
              );
            }).toList(),
            onChanged: (value) {
              onOptionsChanged(options.copyWith(videoQuality: value));
            },
          ),
        ),
        
        SizedBox(height: 16),
        
        // Стиль видео
        _buildOptionCard(
          context: context,
          title: 'Стиль',
          icon: Icons.style,
          child: DropdownButton<String>(
            value: options.videoStyle,
            isExpanded: true,
            items: AppConstants.videoStyles.map((style) {
              return DropdownMenuItem(
                value: style,
                child: Text(style),
              );
            }).toList(),
            onChanged: (value) {
              onOptionsChanged(options.copyWith(videoStyle: value));
            },
          ),
        ),
        
        SizedBox(height: 16),
        
        // Дополнительные опции
        _buildOptionCard(
          context: context,
          title: 'Дополнительно',
          icon: Icons.settings,
          child: Column(
            children: [
              SwitchListTile(
                title: Text('Использовать GPU'),
                subtitle: Text('Ускорение обработки'),
                value: options.useGPU,
                onChanged: (value) {
                  onOptionsChanged(options.copyWith(useGPU: value));
                },
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: Text('Сохранить в облако'),
                subtitle: Text('Автоматическая загрузка результата'),
                value: options.saveToCloud,
                onChanged: (value) {
                  onOptionsChanged(options.copyWith(saveToCloud: value));
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
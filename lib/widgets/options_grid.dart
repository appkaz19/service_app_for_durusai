import 'package:flutter/material.dart';
import '../models/generation_options.dart';
import '../constants/app_constants.dart';
import '../utils/responsive_helper.dart';

class OptionsGrid extends StatelessWidget {
  final GenerationOptions options;
  final Function(GenerationOptions) onOptionsChanged;

  const OptionsGrid({
    super.key,
    required this.options,
    required this.onOptionsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveHelper.getCrossAxisCount(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isMobile ? 3.5 : 2.5,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      children: [
        _buildOptionGroup(
          context,
          '🌍 Language',
          options.language,
          AppConstants.languages,
          (value) => onOptionsChanged(options.copyWith(language: value)),
        ),
        _buildOptionGroup(
          context,
          '⚡ Quality',
          options.quality,
          AppConstants.qualities,
          (value) => onOptionsChanged(options.copyWith(quality: value)),
        ),
        _buildOptionGroup(
          context,
          '🎨 Style',
          options.style,
          AppConstants.styles,
          (value) => onOptionsChanged(options.copyWith(style: value)),
        ),
        _buildOptionGroup(
          context,
          '⏱️ Duration',
          options.duration,
          AppConstants.durations,
          (value) => onOptionsChanged(options.copyWith(duration: value)),
        ),
      ],
    );
  }

  Widget _buildOptionGroup(
    BuildContext context,
    String label,
    String selectedValue,
    Map<String, String> optionsMap,
    Function(String) onChanged,
  ) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.all(isMobile ? 15 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: ResponsiveHelper.getFontSize(context, 14),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedValue,
              onChanged: (value) => onChanged(value!),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 12,
                  vertical: isMobile ? 8 : 12,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 12),
                color: Colors.black,
              ),
              items: optionsMap.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    style: TextStyle(fontSize: ResponsiveHelper.getFontSize(context, 12)),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

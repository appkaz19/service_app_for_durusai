import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_helper.dart';

class OutputSelection extends StatelessWidget {
  final String selectedOutput;
  final Function(String) onOutputSelected;

  const OutputSelection({
    super.key,
    required this.selectedOutput,
    required this.onOutputSelected,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveHelper.getOutputCrossAxisCount(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isMobile ? 1.2 : 1,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        _buildOutputOption(context, '🎤', 'Voice/Speech', 'voice'),
        _buildOutputOption(context, '🎥', 'Video', 'video'),
        _buildOutputOption(context, '🎵', 'Music/Audio', 'audio'),
        _buildOutputOption(context, '✨', 'All Formats', 'all'),
      ],
    );
  }

  Widget _buildOutputOption(BuildContext context, String icon, String label, String type) {
    final isSelected = selectedOutput == type;
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onOutputSelected(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(15),
            gradient: isSelected 
                ? LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.secondaryColor.withOpacity(0.1),
                    ],
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          padding: EdgeInsets.all(isMobile ? 15 : 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                icon,
                style: TextStyle(fontSize: isMobile ? 24 : 32),
              ),
              SizedBox(height: isMobile ? 5 : 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, isMobile ? 10 : 12),
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppTheme.primaryColor : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
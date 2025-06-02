import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/uploaded_file.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_helper.dart';

class UploadSection extends StatefulWidget {
  final UploadedFile? uploadedFile;
  final VoidCallback onUpload;
  final VoidCallback onClear;

  const UploadSection({
    super.key,
    this.uploadedFile,
    required this.onUpload,
    required this.onClear,
  });

  @override
  State<UploadSection> createState() => _UploadSectionState();
}

class _UploadSectionState extends State<UploadSection> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return widget.uploadedFile == null ? _buildUploadArea() : _buildUploadedFileInfo();
  }

  Widget _buildUploadArea() {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onUpload,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            border: Border.all(
              color: _isHovering ? AppTheme.secondaryColor : AppTheme.primaryColor,
              width: 3,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(_isHovering ? 0.1 : 0.05),
                AppTheme.secondaryColor.withOpacity(_isHovering ? 0.1 : 0.05),
              ],
            ),
          ),
          padding: EdgeInsets.all(isMobile ? 30 : 40),
          child: Column(
            children: [
              Text(
                '📁',
                style: TextStyle(fontSize: isMobile ? 48 : 64),
              ),
              const SizedBox(height: 20),
              Text(
                kIsWeb ? 'Click to Upload File' : 'Tap to Upload File',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 20),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Support: Images, Audio, Video, Text files',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: ResponsiveHelper.getFontSize(context, 14),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: widget.onUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 25 : 30, 
                    vertical: isMobile ? 12 : 15
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 8,
                ),
                child: Text(
                  'Choose File',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadedFileInfo() {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.1),
            Colors.teal.withOpacity(0.1),
          ],
        ),
        border: Border.all(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.all(isMobile ? 15 : 20),
      child: Row(
        children: [
          Text(
            widget.uploadedFile!.icon,
            style: TextStyle(fontSize: isMobile ? 24 : 32),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.uploadedFile!.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.getFontSize(context, 16),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Size: ${widget.uploadedFile!.formattedSize}',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: ResponsiveHelper.getFontSize(context, 14),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onClear,
            icon: const Icon(Icons.close),
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

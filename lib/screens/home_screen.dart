import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/generation_options.dart';
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/app_header.dart';
import '../widgets/custom_robot_3d.dart';
import '../widgets/options_grid.dart';
import '../widgets/output_selection.dart';
import '../widgets/generation_progress.dart';
import '../widgets/result_display.dart';
import '../services/api_service.dart';
import '../services/file_service.dart';
import '../models/api_models.dart';
import '../config/app_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  SelectedFile? uploadedImage;
  SelectedFile? uploadedAudio;
  GenerationOptions options = const GenerationOptions(
    language: 'en-US',
    quality: 'standard',
    style: 'natural',
    duration: 'auto',
    outputType: 'video',
  );
  
  GenerationState currentState = GenerationState.input;
  String? currentTaskId;
  TaskResult? lastResult;
  
  final TextEditingController textController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.getHorizontalPadding(context);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                children: [
                  const AppHeader(),
                  const SizedBox(height: 40),
                  
                  if (currentState == GenerationState.input && AppConfig.enable3DRobot) ...[
                    const CustomRobot3D(height: 500),
                    const SizedBox(height: 40),
                  ],
                  
                  _buildMainContent(),
                  
                  const SizedBox(height: 40),
                  if (currentState == GenerationState.input)
                    _buildFeaturesShowcase(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    switch (currentState) {
      case GenerationState.input:
        return _buildInputForm();
      case GenerationState.processing:
        return GenerationProgress(
          taskId: currentTaskId!,
          onCompleted: _onGenerationCompleted,
          onCancel: _onCancelGeneration,
        );
      case GenerationState.completed:
        return ResultDisplay(
          result: lastResult!,
          onNewGeneration: _onNewGeneration,
        );
    }
  }

  Widget _buildInputForm() {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Container(
      constraints: kIsWeb ? const BoxConstraints(maxWidth: 1000) : null,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 50,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 25 : 40),
      child: Column(
        children: [
          _buildStudioHeader(),
          const SizedBox(height: 40),
          _buildFileUploadSection(),
          const SizedBox(height: 30),
          _buildTextInputSection(),
          const SizedBox(height: 30),
          OptionsGrid(
            options: options,
            onOptionsChanged: (newOptions) => setState(() => options = newOptions),
          ),
          const SizedBox(height: 30),
          OutputSelection(
            selectedOutput: options.outputType,
            onOutputSelected: (type) => setState(() => 
              options = options.copyWith(outputType: type)
            ),
          ),
          const SizedBox(height: 30),
          _buildGenerateButton(),
        ],
      ),
    );
  }

  Widget _buildStudioHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.robotGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            ShaderMask(
              shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
              child: Text(
                '${AppConfig.appName} Studio',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 32),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Upload a face image, enter text, and generate realistic talking avatars',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 16),
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      children: [
        _buildUploadCard(
          title: '📸 Face Image',
          subtitle: 'Upload a clear face photo for avatar animation (required)',
          file: uploadedImage,
          onUpload: () => _pickFile(CustomFileType.image),
          onClear: () => setState(() => uploadedImage = null),
          isRequired: true,
        ),
        const SizedBox(height: 20),
        _buildUploadCard(
          title: '🎤 Voice Sample',
          subtitle: 'Upload voice sample for advanced voice cloning (optional)',
          file: uploadedAudio,
          onUpload: () => _pickFile(CustomFileType.audio),
          onClear: () => setState(() => uploadedAudio = null),
          isRequired: false,
        ),
      ],
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required SelectedFile? file,
    required VoidCallback onUpload,
    required VoidCallback onClear,
    required bool isRequired,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isRequired && file == null ? Colors.red.shade300 : Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey.shade50,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 5),
                const Text(
                  '*',
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              ],
            ],
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 15),
          
          if (file == null)
            Center(
              child: ElevatedButton.icon(
                onPressed: onUpload,
                icon: const Icon(Icons.upload_file),
                label: const Text('Choose File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(
                    file.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          file.formattedSize,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onClear,
                    icon: const Icon(Icons.close),
                    color: Colors.red,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextInputSection() {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '📝 Text to Speech',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              '*',
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: textController,
          maxLines: isMobile ? 4 : 6,
          decoration: InputDecoration(
            hintText: AppConstants.sampleText,
            hintStyle: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 14),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: EdgeInsets.all(isMobile ? 15 : 20),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    final isMobile = ResponsiveHelper.isMobile(context);
    final canGenerate = _canGenerate();
    
    return SizedBox(
      width: double.infinity,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: ElevatedButton(
          onPressed: canGenerate ? _generateContent : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canGenerate ? AppTheme.accentColor : Colors.grey,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: isMobile ? 15 : 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            elevation: canGenerate ? 10 : 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.rocket_launch),
              const SizedBox(width: 8),
              Text(
                'GENERATE ${AppConfig.appName.toUpperCase()} AVATAR',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 16),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesShowcase() {
    final isMobile = ResponsiveHelper.isMobile(context);
    final crossAxisCount = isMobile ? 1 : 2;
    
    return Container(
      constraints: kIsWeb ? const BoxConstraints(maxWidth: 1000) : null,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.all(isMobile ? 20 : 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.robotBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Powered by ${AppConfig.appName} AI',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 28),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: isMobile ? 3 : 1.2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            children: const [
              _FeatureItem(
                title: '🎭 Neural Facial Animation',
                description: 'Advanced AI-powered lip sync and realistic expressions',
              ),
              _FeatureItem(
                title: '🎤 Multi-Language TTS',
                description: 'Natural speech synthesis in multiple languages',
              ),
              _FeatureItem(
                title: '🎨 Voice Cloning',
                description: 'Clone any voice from just a few seconds of audio',
              ),
              _FeatureItem(
                title: '⚡ Real-time Processing',
                description: 'Fast generation with live progress tracking',
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _canGenerate() {
    return uploadedImage != null && textController.text.trim().isNotEmpty;
  }

  Future<void> _pickFile(CustomFileType fileType) async {
    try {
      final file = await FileService.pickFile();
      if (file != null) {
        if (fileType == CustomFileType.image && !FileService.isValidImageFile(file)) {
          _showSnackBar('Please select a valid image file (max ${AppConfig.maxImageSizeMB}MB)');
          return;
        }
        
        if (fileType == CustomFileType.audio && !FileService.isValidAudioFile(file)) {
          _showSnackBar('Please select a valid audio file (max ${AppConfig.maxAudioSizeMB}MB)');
          return;
        }

        setState(() {
          if (fileType == CustomFileType.image) {
            uploadedImage = file;
          } else if (fileType == CustomFileType.audio) {
            uploadedAudio = file;
          }
        });
        
        _showSnackBar('File uploaded successfully!');
      }
    } catch (e) {
      _showSnackBar('Error uploading file: ${e.toString()}');
    }
  }

  Future<void> _generateContent() async {
    if (!_canGenerate()) {
      _showSnackBar('Please upload a face image and enter text');
      return;
    }

    try {
      setState(() {
        currentState = GenerationState.processing;
      });

      final response = await ApiService.generateContent(
        imageBytes: uploadedImage!.bytes,
        text: textController.text.trim(),
        language: ApiService.convertLanguageCode(options.language),
        speakerAudioBytes: uploadedAudio?.bytes,
        imageFileName: uploadedImage!.name,
        audioFileName: uploadedAudio?.name,
      );

      setState(() {
        currentTaskId = response.taskId;
      });

    } catch (e) {
      setState(() {
        currentState = GenerationState.input;
      });
      
      String errorMessage = '${AppConfig.appName} generation failed';
      if (e is ApiException) {
        errorMessage = e.message;
      }
      
      _showSnackBar(errorMessage);
    }
  }

  void _onGenerationCompleted(TaskResult result) {
    setState(() {
      currentState = GenerationState.completed;
      lastResult = result;
    });
  }

  void _onCancelGeneration() {
    setState(() {
      currentState = GenerationState.input;
      currentTaskId = null;
    });
  }

  void _onNewGeneration() {
    setState(() {
      currentState = GenerationState.input;
      currentTaskId = null;
      lastResult = null;
      textController.clear();
      uploadedImage = null;
      uploadedAudio = null;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

enum GenerationState { input, processing, completed }

class _FeatureItem extends StatelessWidget {
  final String title;
  final String description;

  const _FeatureItem({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.all(isMobile ? 15 : 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: ResponsiveHelper.getFontSize(context, 14),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 5 : 10),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey,
              fontSize: ResponsiveHelper.getFontSize(context, 12),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
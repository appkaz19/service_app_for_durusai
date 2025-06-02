import 'package:flutter/material.dart';
import '../models/api_models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class GenerationProgress extends StatefulWidget {
  final String taskId;
  final Function(TaskResult) onCompleted;
  final VoidCallback? onCancel;

  const GenerationProgress({
    super.key,
    required this.taskId,
    required this.onCompleted,
    this.onCancel,
  });

  @override
  State<GenerationProgress> createState() => _GenerationProgressState();
}

class _GenerationProgressState extends State<GenerationProgress>
    with TickerProviderStateMixin {
  late Stream<TaskResult> _taskStream;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _taskStream = ApiService.pollTaskResult(widget.taskId);
    _progressController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              const Text(
                '🎬 DURUSAI Generating',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          StreamBuilder<TaskResult>(
            stream: _taskStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final result = snapshot.data!;

                if (result.isCompleted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    widget.onCompleted(result);
                  });
                }

                if (result.isFailed) {
                  return _buildError(result.error ?? 'Unknown error');
                }

                return _buildProgress(result);
              }

              if (snapshot.hasError) {
                return _buildError(snapshot.error.toString());
              }

              return _buildProgress(TaskResult(
                taskId: widget.taskId,
                status: ApiService.statusPending,
              ));
            },
          ),
          const SizedBox(height: 20),
          if (widget.onCancel != null)
            TextButton.icon(
              onPressed: widget.onCancel,
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgress(TaskResult result) {
    String statusText;
    IconData statusIcon;
    Color statusColor;

    switch (result.status) {
      case ApiService.statusPending:
        statusText = 'Queued for processing...';
        statusIcon = Icons.schedule;
        statusColor = Colors.orange;
        break;
      case ApiService.statusProcessing:
        statusText = 'DURUSAI AI is working on your avatar...';
        statusIcon = Icons.psychology;
        statusColor = AppTheme.primaryColor;
        break;
      case ApiService.statusSuccess:
        statusText = 'Avatar generation completed!';
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        break;
      default:
        statusText = 'Processing with advanced AI...';
        statusIcon = Icons.autorenew;
        statusColor = AppTheme.secondaryColor;
    }

    return Column(
      children: [
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_progressAnimation.value * 0.1),
              child: Icon(
                statusIcon,
                size: 64,
                color: statusColor,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          statusText,
          style: TextStyle(
            fontSize: 16,
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        if (result.status != ApiService.statusSuccess) ...[
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Neural networks are processing your request...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Task ID: ${widget.taskId}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(String error) {
    return Column(
      children: [
        const Icon(
          Icons.error_outline,
          size: 64,
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        const Text(
          'Generation Failed',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          error,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: widget.onCancel,
          icon: const Icon(Icons.refresh),
          label: const Text('Try Again'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

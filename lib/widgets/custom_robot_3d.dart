import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../utils/responsive_helper.dart';
import '../theme/app_theme.dart';

class CustomRobot3D extends StatefulWidget {
  final double height;
  final bool interactive;

  const CustomRobot3D({
    super.key,
    this.height = 500,
    this.interactive = true,
  });

  @override
  State<CustomRobot3D> createState() => _CustomRobot3DState();
}

class _CustomRobot3DState extends State<CustomRobot3D>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _floatController;
  late AnimationController _eyeController;
  
  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _eyeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _floatController.dispose();
    _eyeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    print('🤖 Строим CustomRobot3D: kIsWeb=$kIsWeb, enable3DRobot=${AppConfig.enable3DRobot}');
    
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: kIsWeb && AppConfig.enable3DRobot
            ? _buildWebGL3D()
            : _buildFallbackRobot(),
      ),
    );
  }

  Widget _buildWebGL3D() {
    print('🌐 Показываем WebGL 3D робота');
    return const HtmlElementView(
      viewType: 'durusai-3d-robot',
    );
  }

  Widget _buildFallbackRobot() {
    print('🎨 Показываем Flutter fallback робота');
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.2),
            AppTheme.secondaryColor.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _rotationController,
            _floatController,
            _eyeController,
          ]),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatController.value * 20 - 10),
              child: Transform.rotate(
                angle: _rotationController.value * 0.3,
                child: _buildRobotWidget(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRobotWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Антенна
        Container(
          width: 4,
          height: 30,
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.robotBlue.withOpacity(0.3),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        // Светящийся шарик
        AnimatedBuilder(
          animation: _eyeController,
          builder: (context, child) {
            return Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _eyeController.value > 0.5 
                    ? AppTheme.robotBlue 
                    : AppTheme.robotBlue.withOpacity(0.5),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.robotBlue,
                    blurRadius: _eyeController.value * 15,
                    spreadRadius: _eyeController.value * 3,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        
        // Голова
        Container(
          width: 100,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppTheme.robotGradient,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Левый глаз
              AnimatedBuilder(
                animation: _eyeController,
                builder: (context, child) {
                  return Container(
                    width: 16,
                    height: _eyeController.value > 0.8 ? 4 : 16,
                    decoration: BoxDecoration(
                      color: AppTheme.robotBlue,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.robotBlue.withOpacity(0.8),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Правый глаз
              AnimatedBuilder(
                animation: _eyeController,
                builder: (context, child) {
                  return Container(
                    width: 16,
                    height: _eyeController.value > 0.8 ? 4 : 16,
                    decoration: BoxDecoration(
                      color: AppTheme.robotBlue,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.robotBlue.withOpacity(0.8),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        
        // Тело
        Container(
          width: 120,
          height: 150,
          decoration: BoxDecoration(
            gradient: AppTheme.robotGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Логотип на груди
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.robotBlue.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 15),
              // Индикаторы
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _eyeController,
                    builder: (context, child) {
                      final delay = index * 0.3;
                      final value = (_eyeController.value + delay) % 1.0;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: value > 0.5 
                              ? AppTheme.robotBlue 
                              : Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                          boxShadow: value > 0.5 ? [
                            BoxShadow(
                              color: AppTheme.robotBlue,
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ] : null,
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Название с эффектами
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, AppTheme.robotBlue],
          ).createShader(bounds),
          child: const Text(
            '🤖 DURUSAI',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.robotBlue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: const Text(
            'Advanced AI Avatar Generation',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
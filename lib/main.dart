
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;

void main() {
  if (kIsWeb) {
    print('🤖 Регистрируем 3D робота...');
    _register3DRobot();
  }

  runApp(const DurusAIApp());
}

void _register3DRobot() {
  ui.platformViewRegistry.registerViewFactory(
    'durusai-3d-robot',
    (int viewId) {
      final containerId = 'robot-container-\$viewId';

      final div = html.DivElement()
        ..id = containerId
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none'
        ..style.background = 'transparent'
        ..style.position = 'relative';

      div.innerHtml = '''
        <div style="
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          height: 100%;
          color: white;
          font-family: Arial;
        ">
          <div style="
            width: 40px;
            height: 40px;
            border: 4px solid rgba(255,255,255,0.3);
            border-top: 4px solid #00ffff;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-bottom: 16px;
          "></div>
          <div>Loading 3D Robot...</div>
        </div>
        <style>
          @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
          }
        </style>
      ''';

      _loadThreeJSAndCreateRobot(containerId);
      return div;
    },
  );
}

void _loadThreeJSAndCreateRobot(String containerId) {
  void createRobot() {
    final js = html.ScriptElement()
      ..type = 'application/javascript'
      ..innerHtml = '''
          (function() {
            const container = document.getElementById("\$containerId");
            if (!container) return;
            container.innerHTML = '';

            const scene = new THREE.Scene();
            const camera = new THREE.PerspectiveCamera(75, 1, 0.1, 1000);
            const renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true });
            renderer.setSize(container.clientWidth, container.clientHeight);
            container.appendChild(renderer.domElement);

            const ambientLight = new THREE.AmbientLight(0x404040);
            scene.add(ambientLight);

            const robot = new THREE.Mesh(
              new THREE.BoxGeometry(1, 1, 1),
              new THREE.MeshStandardMaterial({ color: 0x00ffff })
            );
            scene.add(robot);
            camera.position.z = 5;

            function animate() {
              requestAnimationFrame(animate);
              robot.rotation.x += 0.01;
              robot.rotation.y += 0.01;
              renderer.render(scene, camera);
            }
            animate();
          })();
        ''';

    html.document.body!.append(js);
  }

  final existing =
      html.document.head!.querySelector('script[src*="three.min.js"]');

  if (existing != null) {
    createRobot();
  } else {
    final script = html.ScriptElement()
      ..src =
          'https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js'
      ..onLoad.listen((_) {
        createRobot();
      });

    html.document.head!.append(script);
  }
}

class DurusAIApp extends StatelessWidget {
  const DurusAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DurusAI Robot',
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: SizedBox(
            width: 600,
            height: 600,
            child: HtmlElementView(viewType: 'durusai-3d-robot'),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
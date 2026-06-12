import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '/features/player/controllers/player_controller.dart';

class PlayerVideoBox extends StatelessWidget {
  final PlayerController controller;

  const PlayerVideoBox({super.key, required this.controller});

  

@override
Widget build(BuildContext context) {
  print('📐 Loading: ${controller.loading}');
  
  return LayoutBuilder(
  builder: (context, constraints) {
    return Stack(
      children: [
        // Video SIEMPRE visible en el árbol
        Video(controller: controller.videoController),
        
        // Spinner encima mientras carga
        if (controller.loading)
          const ColoredBox(
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
            ),
          ),
          
        // Error encima si falla
        if (controller.error != null)
          ColoredBox(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    controller.error!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  },
);
}
}


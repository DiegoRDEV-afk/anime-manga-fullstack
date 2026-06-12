import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlayerController extends ChangeNotifier {
  late final Player player;
  late final VideoController videoController;

  bool loading = true;
  String? error;

  PlayerController() {
      player = Player(
        configuration: const PlayerConfiguration(
          bufferSize: 32 * 1024 * 1024, // 32MB de buffer
        ),
      );
        videoController = VideoController(
          player,
          configuration: const VideoControllerConfiguration(
            enableHardwareAcceleration: false,
            width: 1280,
            height: 720,
          ),
        );
    }

  Future<void> loadVideo(String urlEpisodio) async {
    loading = true;
    error = null;
    if (hasListeners) notifyListeners();

    try {
      print('🎬 Llamando backend: $urlEpisodio');
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/video?url=${Uri.encodeComponent(urlEpisodio)}'),
      );
      print('✅ Backend respondió: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode != 200) throw Exception('Error del servidor');

      final data = jsonDecode(response.body);
      if (data['success'] != true) throw Exception('El backend no devolvió éxito');

      final String videoUrl = data['url'];
      final String referer = data['referer'] ?? 'https://streamwish.to/';

      if (!hasListeners) return;

    await player.open(Media(
      videoUrl,
      httpHeaders: {
        'Referer': referer,
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
    ));

      print('▶️ Esperando video...');

      await player.stream.buffer
    .firstWhere((buffer) => buffer.inSeconds > 5)
    .timeout(const Duration(seconds: 30), onTimeout: () => Duration.zero);

      print('🟢 Video listo');
      loading = false;
    } catch (e) {
      print('❌ Error: $e');
      loading = false;
      error = e.toString();
    } finally {
      if (hasListeners) notifyListeners();
    }
  }

  void disposePlayer() {
    player.dispose();
  }
}
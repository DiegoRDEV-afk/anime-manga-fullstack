import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlayerController extends ChangeNotifier {
    bool loading = true;
    String? error;
    
    // Guardamos las variables que necesita el WebView
    String? videoUrl;
    String? referer;
    
    // 🟢 ESTA VARIABLE ES LA QUE LE FALTA A TU COMPILADOR
    String? scriptAntiAnuncios;

    PlayerController();

    Future<void> loadVideo(String urlEpisodio) async {
        loading = true;
        error = null;
        videoUrl = null;
        referer = null;
        scriptAntiAnuncios = null; 
        if (hasListeners) notifyListeners();

        try {
            print('🎬 Llamando backend: $urlEpisodio');
            
            final response = await http.get(
                Uri.parse('http://localhost:3000/api/anime/video?url=${Uri.encodeComponent(urlEpisodio)}'),
            );
            
            print('✅ Backend respondió: ${response.statusCode}');

            if (response.statusCode != 200) throw Exception('Error del servidor');

            final responseData = jsonDecode(response.body);
            if (responseData['success'] != true) throw Exception('El backend no devolvió éxito');

            // Capturamos el escudo anti-anuncios del backend
            scriptAntiAnuncios = responseData['scriptBlinder'];

            final dataField = responseData['data'];
            if (dataField != null && dataField['servers'] != null) {
                final List<dynamic> servidoresSub = dataField['servers']['sub'] ?? [];
                
                if (servidoresSub.isNotEmpty) {
                    final primerServidor = servidoresSub[0];
                    videoUrl = primerServidor['url'];
                    referer = responseData['referer'] ?? '${Uri.parse(videoUrl!).scheme}://${Uri.parse(videoUrl!).host}/';
                    print('🔗 URL del video obtenida con éxito: $videoUrl');
                } else {
                    throw Exception('La lista de servidores "sub" viene vacía');
                }
            } else {
                throw Exception('No se encontró el nodo "data" o "servers"');
            }

            loading = false;
        } catch (e) {
            print('❌ Error en PlayerController: $e');
            loading = false;
            error = e.toString();
        } finally {
            if (hasListeners) notifyListeners();
        }
    }

    void disposePlayer() {}
}
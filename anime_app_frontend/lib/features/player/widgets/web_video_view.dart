import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebVideoView extends StatefulWidget {
  final String videoUrl;

  const WebVideoView({super.key, required this.videoUrl});

  @override
  State<WebVideoView> createState() => _WebVideoViewState();
}

class _WebVideoViewState extends State<WebVideoView> {
  late final WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Extraemos el dominio base de la URL para usarlo como 'Referer' dinámico
    final uri = Uri.parse(widget.videoUrl);
    final String refererUrl = '${uri.scheme}://${uri.host}/';

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Permite que corra el reproductor de la web
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            // TRUCO DE ORO: Las webs piratas intentan abrir ventanas de publicidad (popups).
            // Si la URL a la que se quiere mover no es la del video original, la bloqueamos por completo.
            if (!request.url.contains(uri.host)) {
              print('🚫 Intento de publicidad bloqueado: ${request.url}');
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    // Cargamos la URL inyectando las cabeceras personalizadas que engañan al servidor
    _webViewController.loadRequest(
      Uri.parse(widget.videoUrl),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
        'Referer': refererUrl,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // El reproductor web real corriendo de fondo
        WebViewWidget(controller: _webViewController),

        // Pantalla de carga estética mientras el búfer inicial responde
        if (_isLoading)
          Container(
            color: const Color(0xff121214),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff8a3ffc)), // Tu morado insignia
              ),
            ),
          ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../controllers/player_controller.dart';

class PlayerVideoBox extends StatefulWidget {
    final PlayerController controller;

    const PlayerVideoBox({super.key, required this.controller});

    @override
    State<PlayerVideoBox> createState() => _PlayerVideoBoxState();
}

class _PlayerVideoBoxState extends State<PlayerVideoBox> {
    String? _currentUrl;

    final InAppWebViewSettings _webViewSettings = InAppWebViewSettings(
        javaScriptEnabled: true,
        supportMultipleWindows: false, // 🚫 Evita popups externos nativos
        javaScriptCanOpenWindowsAutomatically: false, // 🚫 Bloquea window.open masivo
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
    );

    @override
    Widget build(BuildContext context) {
        final videoUrl = widget.controller.videoUrl;

        if (widget.controller.loading) {
            return Container(
                color: Colors.black,
                child: const Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xff8a3ffc)),
                    ),
                ),
            );
        }

        if (widget.controller.error != null) {
            return Container(
                color: const Color(0xFF1A1A1A),
                child: Center(
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                            width: double.infinity,
                            child: Text(
                                '❌ Error: ${widget.controller.error}',
                                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                                textAlign: TextAlign.center,
                            ),
                        ),
                    ),
                ),
            );
        }

        return Container(
            color: Colors.black,
            child: videoUrl != null
                ? InAppWebView(
                    initialUrlRequest: URLRequest(
                        url: WebUri(videoUrl),
                        headers: {
                            'Referer': widget.controller.referer ?? '${Uri.parse(videoUrl).scheme}://${Uri.parse(videoUrl).host}/',
                        },
                    ),
                    initialSettings: _webViewSettings,
                    onLoadStart: (controller, url) async {
                        _currentUrl = url?.toString();
                        
                        if (widget.controller.scriptAntiAnuncios != null) {
                            await controller.evaluateJavascript(
                                source: widget.controller.scriptAntiAnuncios!
                            );
                            print('🟢 [InAppWebView] Escudo del Backend inyectado con éxito');
                        }
                    },
                    onUpdateVisitedHistory: (controller, url, isReload) {
                        final currentHost = url?.host ?? '';
                        final baseUri = Uri.parse(videoUrl);
                        
                        if (currentHost.isNotEmpty && 
                            !currentHost.contains(baseUri.host) && 
                            url?.toString() != "about:blank") {
                            print('🚫 [InAppWebView] Intento de desvío bloqueado: $url');
                            controller.goBack();
                        }
                    },
                )
                : const Center(
                    child: Text(
                        'No hay video cargado',
                        style: TextStyle(color: Colors.grey),
                    ),
                ),
        );
    }
}
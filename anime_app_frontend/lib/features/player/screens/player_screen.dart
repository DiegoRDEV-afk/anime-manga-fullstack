import 'package:flutter/material.dart';
import '../controllers/player_controller.dart';
import '../widgets/player_video_box.dart';
import '../widgets/episode_info_block.dart';
import '../widgets/navigation_episodes_column.dart';

class PlayerScreen extends StatefulWidget {
    final String urlEpisodio;
    final String tituloAnime;
    final String tituloEpisodio;
    final String? urlEpisodioAnterior;
    final String? urlEpisodioSiguiente;

    const PlayerScreen({
        super.key,
        required this.urlEpisodio,
        required this.tituloAnime,
        required this.tituloEpisodio,
        this.urlEpisodioAnterior,
        this.urlEpisodioSiguiente,
    });

    @override
    State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
    late final PlayerController _controller;

    @override
    void initState() {
        super.initState();
        _controller = PlayerController();
        _controller.loadVideo(widget.urlEpisodio);
    }

    @override
    void dispose() {
        _controller.disposePlayer();
        _controller.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        final screenSize = MediaQuery.of(context).size;

        return Scaffold(
            backgroundColor: const Color(0xFF121212),
            body: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                    return Column(
                        children: [
                            
                            // ── VIDEO CON ALTURA FIJA ────────────────────────────────
                            SizedBox(
                                height: screenSize.height * 0.65,
                                width: double.infinity,
                                child: PlayerVideoBox(controller: _controller),
                            ),

                            // ── DETALLES ABAJO ───────────────────────────────────────
                            Expanded(
                                child: SingleChildScrollView(
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                                        child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [

                                                // Bloque izquierdo: Título y info del episodio
                                                Expanded(
                                                    child: EpisodeInfoBlock(
                                                        tituloAnime: widget.tituloAnime,
                                                        tituloEpisodio: widget.tituloEpisodio,
                                                    ),
                                                ),

                                                const SizedBox(width: 40),

                                                // Bloque derecho: Siguiente / Anterior
                                                SizedBox(
                                                    width: 300,
                                                    child: NavigationEpisodesColumn(
                                                        urlEpisodioAnterior: widget.urlEpisodioAnterior,
                                                        urlEpisodioSiguiente: widget.urlEpisodioSiguiente,
                                                        onEpisodeTap: (url) => _controller.loadVideo(url),
                                                    ),
                                                ),

                                            ],
                                        ),
                                    ),
                                ),
                            ),

                        ],
                    );
                },
            ),
        );
    }
}
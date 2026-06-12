import 'package:flutter/material.dart';

class NavigationEpisodesColumn extends StatelessWidget {
  final String? urlEpisodioAnterior;
  final String? urlEpisodioSiguiente;
  final Function(String) onEpisodeTap;

  const NavigationEpisodesColumn({
    super.key,
    this.urlEpisodioAnterior,
    this.urlEpisodioSiguiente,
    required this.onEpisodeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (urlEpisodioSiguiente != null) ...[
          const Text(
            'SIGUIENTE EPISODIO',
            style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => onEpisodeTap(urlEpisodioSiguiente!),
            child: _buildEpisodeThumbnail(),
          ),
          const SizedBox(height: 20),
        ],
        if (urlEpisodioAnterior != null) ...[
          const Text(
            'EPISODIO ANTERIOR',
            style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => onEpisodeTap(urlEpisodioAnterior!),
            child: _buildEpisodeThumbnail(),
          ),
        ],
      ],
    );
  }

  Widget _buildEpisodeThumbnail() {
    return Container(
      width: 160,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.play_circle_fill, color: Colors.white54, size: 36),
      ),
    );
  }
}
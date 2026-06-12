import 'package:flutter/material.dart';

class EpisodeInfoBlock extends StatelessWidget {
  final String tituloAnime;
  final String tituloEpisodio;

  const EpisodeInfoBlock({
    super.key,
    required this.tituloAnime,
    required this.tituloEpisodio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tituloAnime,
          style: const TextStyle(
            color: Color(0xFF7C3AED),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          tituloEpisodio,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import '../../data/models/anime_model.dart';

class AnimeCard extends StatelessWidget {
  final AnimeModel anime;
  final VoidCallback? onTap;

  const AnimeCard({super.key, required this.anime, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 16),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(9),
          image: anime.imagen != null
              ? DecorationImage(
                  image: NetworkImage(anime.imagen!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent, 
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.95),
                    ],
                  stops: const [0.5, 0.75, 1.0],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                anime.titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    )
                  ]
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
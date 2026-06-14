import 'package:flutter/material.dart';
import '../../../shared/widgets/anime_card.dart';

class AnimeGrid extends StatelessWidget {
  const AnimeGrid({super.key});

  @override
  Widget build(BuildContext context) {

    final animes = [];

    return GridView.builder(
      padding: const EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 24), // top: 90 = altura del UpperBar
      itemCount: animes.length,
      gridDelegate:
        
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 15,
        mainAxisSpacing: 20,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, index) {

        return AnimeCard(
          anime: animes[index],
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/home_controller.dart';
import '../../../shared/widgets/seccion_horizontal.dart';
import '../widgets/hero_banner_slider.dart';
import '../../anime_detail/screens/anime_detail_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeController>().cargarContenidoHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: CustomScrollView(
        slivers: [

          // ── HERO BANNER ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Consumer<HomeController>(
              builder: (context, controller, _) {
                if (controller.estaCargando) {
                  return Container(
                    height: 550,
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
                    ),
                  );
                }
                if (controller.animesTop.isEmpty) {
                  return Container(
                    height: 550,
                    color: const Color(0xFF1A1A1A),
                    child: const Center(
                      child: Icon(Icons.movie_filter, color: Colors.white24, size: 64),
                    ),
                  );
                }
                return HeroBannerSlider(items: controller.animesTop);
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 48)),

          // ── TÍTULOS POPULARES ────────────────────────────────────
          SliverToBoxAdapter(
            child: Consumer<HomeController>(
              builder: (context, controller, _) {
                return SeccionHorizontal(
                  titulo: 'Títulos Populares',
                  items: controller.animesPopulares,
                  estaCargando: controller.estaCargando,
                  onAnimeTap: (anime) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AnimeDetailScreen(animeId: anime.urlAnime),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),

          // ── NUEVOS ESTA TEMPORADA ────────────────────────────────
          SliverToBoxAdapter(
            child: Consumer<HomeController>(
              builder: (context, controller, _) {
                return SeccionHorizontal(
                  titulo: 'Nuevos esta Temporada',
                  items: controller.animesNovedades,
                  estaCargando: controller.estaCargando,
                  onAnimeTap: (anime) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AnimeDetailScreen(animeId: anime.urlAnime),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),

          // ── NUEVOS EPISODIOS ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Consumer<HomeController>(
              builder: (context, controller, _) {
                return SeccionHorizontal(
                  titulo: 'Nuevos Episodios',
                  items: controller.ultimosEpisodios,
                  estaCargando: controller.estaCargando,
                  onAnimeTap: (anime) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AnimeDetailScreen(animeId: anime.urlAnime),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
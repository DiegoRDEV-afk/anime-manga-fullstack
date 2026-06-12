import 'dart:ui';
import 'package:anime_frontend/features/home/screens/home_screen.dart';
import 'package:flutter/material.dart';
import '../controllers/anime_detail_controller.dart';
import '../../../features/player/screens/player_screen.dart';

class AnimeDetailScreen extends StatefulWidget {
  final String animeId;
  const AnimeDetailScreen({super.key, required this.animeId});

  @override
  State<AnimeDetailScreen> createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends State<AnimeDetailScreen> {
  late AnimeDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimeDetailController();
    _controller.cargarDetalleAnime(widget.animeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.estaCargando) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
            );
          }

          if (_controller.errorMensaje != null) {
            return Center(
              child: Text(
                _controller.errorMensaje!,
                style: const TextStyle(color: Colors.white38, fontSize: 16),
              ),
            );
          }

          final anime = _controller.animeDetalle!;

          return Stack(
            children: [
              // IMAGEN DE FONDO DIFUMINADA
              Container(
                height: 450,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(anime.imagen!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(color: Colors.black.withOpacity(0.5)),
                ),
              ),

              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xFF121212)],
                      stops: [0.2, 0.6],
                    ),
                  ),
                ),
              ),


              SingleChildScrollView(
                padding: const EdgeInsets.only(top: 160, left: 24, right: 24, bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── FILA PRINCIPAL ──────────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // COLUMNA IZQUIERDA: Portada + Botones
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                anime.imagenPortada,
                                width: 271,
                                height: 386,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    if (anime.episodios.isNotEmpty) {}
                                  },
                                  icon: const Icon(Icons.play_arrow, color: Colors.white, size: 27),
                                  label: const Text(
                                    "Continuar Viendo",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7C3AED),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.bookmark_border, color: Colors.white, size: 22),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(width: 24),

                        // COLUMNA CENTRAL: Calificación, Título, Sinopsis
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 200),
                              // Estrellas + calificación
                              Row(
                                children: [
                                  ...List.generate(5, (index) {
                                    final rating = anime.calificacion / 2;
                                    return Icon(
                                      index < rating.floor()
                                          ? Icons.star
                                          : index < rating
                                              ? Icons.star_half
                                              : Icons.star_border,
                                      color: Colors.amber,
                                      size: 18,
                                    );
                                  }),
                                  const SizedBox(width: 8),
                                  Text(
                                    anime.calificacion.toString(),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Título
                              Text(
                                anime.titulo.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Sinopsis
                              Text(
                                anime.sinopsis,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 24),

                        // COLUMNA DERECHA: Info del anime
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 240),

                            const SizedBox(height: 40),
                            _InfoItem(label: 'Géneros', value: anime.generos.join(', ')),
                            const SizedBox(height: 10),
                            _InfoItem(label: 'Estado', value: anime.estado),
                            const SizedBox(height: 10),
                            _InfoItem(label: 'Tipo', value: anime.tipo),
                            const SizedBox(height: 10),
                            _InfoItem(label: 'Episodios', value: anime.totalEpisodios.toString()),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    Container(height: 1, color: Colors.white12),
                    const SizedBox(height: 20),

                    // ── SELECTOR TEMPORADA ──────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "Temporada 1",
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── CARRUSEL DE EPISODIOS ───────────────────────────
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: anime.episodios.length,
                        itemBuilder: (context, index) {
                          final ep = anime.episodios[index];
                          return Container(
                            width: 180,
                            margin: const EdgeInsets.only(right: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        ep.miniatura,
                                        width: 180,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: Colors.white10,
                                          height: 100,
                                          child: const Icon(Icons.movie, color: Colors.white24),
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Container(
                                        color: Colors.black.withOpacity(0.2),
                                        child: Center(
                                          child: IconButton(
                                            icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 36),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => PlayerScreen(
                                                    urlEpisodio: ep.urlVer,
                                                    tituloAnime: anime.titulo,
                                                    tituloEpisodio: ep.tituloEpisodio,
                                                  ),
                                                )
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  ep.tituloEpisodio,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // BOTÓN ATRÁS
              Positioned(
                top: 40,
                left: 16,
                child: SafeArea( // 🟢 Esto evita que el notch de la pantalla tape el botón
                  child: Material(
                    color: Colors.black.withOpacity(0.3), // Un fondo semi-transparente ayuda a verlo mejor
                    borderRadius: BorderRadius.circular(50),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        // El Navigator aquí es totalmente válido
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const HomePage()),
                            (route) => false,
                          );
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      ),
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

// ── WIDGET AUXILIAR: Item de info ───────────────────────
class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
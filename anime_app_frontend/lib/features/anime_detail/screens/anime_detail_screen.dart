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
          final animeDetalle = _controller.animeDetalle;
          final seasons = animeDetalle?.seasons ?? [];

          return Stack(
            children: [

              // ── IMAGEN DE FONDO DIFUMINADA ──────────────────────────
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

              // ── GRADIENTE SUPERIOR→FONDO ────────────────────────────
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

              // ── CONTENIDO PRINCIPAL ─────────────────────────────────
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
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7C3AED),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
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
                              Text(
                                anime.titulo.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 12),
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

                    // ── SELECTOR DE TEMPORADA ───────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: seasons.any((s) => s.url == _controller.urlTemporadaActual)
                              ? _controller.urlTemporadaActual
                              : seasons.isNotEmpty
                                  ? seasons.first.url
                                  : null,
                          dropdownColor: const Color(0xFF1E1E1E),
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white70,
                            size: 18,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          items: seasons.map<DropdownMenuItem<String>>((season) {
                            return DropdownMenuItem<String>(
                              value: season.url,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 200),
                                child: Text(
                                  "${season.title} (${season.episodesCount} CAPS)",
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newSeasonUrl) async {
                            if (newSeasonUrl == null) return;
                            await _controller.cambiarTemporada(newSeasonUrl);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── GRID DE EPISODIOS ESTILO CRUNCHYROLL ────────────
                    if (_controller.cargandoEpisodios)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 20,
                          // 16:9 miniatura + espacio para texto abajo
                          childAspectRatio: 16 / 13,
                        ),
                        itemCount: anime.episodios.length,
                        itemBuilder: (context, index) {
                          final ep = anime.episodios[index];
                          final tituloEp = ep.tituloEpisodio.isNotEmpty
                              ? ep.tituloEpisodio
                              : 'Episodio ${ep.numero}';

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlayerScreen(
                                    urlEpisodio: ep.urlVer,
                                    tituloAnime: anime.titulo,
                                    tituloEpisodio: tituloEp,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                // ── MINIATURA 16:9 ──────────────────────
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Stack(
                                    children: [
                                      // Imagen
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.network(
                                          ep.miniatura,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white10,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Icon(
                                              Icons.movie,
                                              color: Colors.white24,
                                              size: 28,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Overlay sutil + ícono play
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(6),
                                            color: Colors.black.withOpacity(0.15),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.play_circle_outline,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 6),

                                // ── NOMBRE DEL ANIME (gris pequeño) ────
                                Text(
                                  anime.titulo.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),

                                const SizedBox(height: 2),

                                // ── TÍTULO DEL EPISODIO (blanco bold) ──
                                Text(
                                  'E${ep.numero} – $tituloEp',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),

              // ── BOTÓN ATRÁS ─────────────────────────────────────────
              Positioned(
                top: 40,
                left: 16,
                child: SafeArea(
                  child: Material(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(50),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
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
import 'package:flutter/material.dart';
import '../../../data/models/anime_model.dart';
import 'anime_card.dart';

class SeccionHorizontal extends StatefulWidget {
  final String titulo;
  final List<AnimeModel> items;
  final bool estaCargando;
  final Function(AnimeModel)? onAnimeTap;

  const SeccionHorizontal({
    super.key,
    required this.titulo,
    required this.items,
    required this.estaCargando,
    this.onAnimeTap,
  });

  @override
  State<SeccionHorizontal> createState() => _SeccionHorizontalState();
}

class _SeccionHorizontalState extends State<SeccionHorizontal> {
  // 🔑 Controlador para manejar el desplazamiento
  final ScrollController _scrollController = ScrollController();

  // Función para mover la lista suavemente
  void _scroll(double offset) {
    _scrollController.animateTo(
      _scrollController.offset + offset,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic, // Animación suave premium
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= TITULO SECCIÓN =================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0),
          child: Text(
            widget.titulo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ================= CARRUSEL CON BOTONES =================
        SizedBox(
          height: 270,
          child: widget.estaCargando
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)))
              : widget.items.isEmpty
                  ? const Center(
                      child: Text(
                        'Sin contenido disponible.',
                        style: TextStyle(color: Colors.white38),
                      ),
                    )
                  : Stack(
                      children: [
                        // 1. LA LISTA HORIZONTAL (Se extiende por toda la pantalla)
                        ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          // 🟢 Clave: El padding ahora es interno para que el scroll se vea fluido de fondo
                          padding: const EdgeInsets.symmetric(horizontal: 48.0),
                          itemCount: widget.items.length,
                          itemBuilder: (context, index) {
                            return AnimeCard(
                              anime: widget.items[index],
                              onTap: widget.onAnimeTap != null
                                  ? () => widget.onAnimeTap!(widget.items[index])
                                  : null,
                            );
                          },
                        ),

                        // 2. BOTÓN IZQUIERDO (Aparece alineado con el inicio del texto)
                        Positioned(
                          left: 24,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _buildScrollButton(
                              icon: Icons.arrow_back_ios_new,
                              onPressed: () => _scroll(-500), // Desplaza a la izquierda
                            ),
                          ),
                        ),

                        // 3. BOTÓN DERECHO (Aparece alineado al extremo derecho)
                        Positioned(
                          right: 24,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _buildScrollButton(
                              icon: Icons.arrow_forward_ios,
                              onPressed: () => _scroll(500), // Desplaza a la derecha
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ],
    );
  }

  // --- BOTÓN FLOTANTE ESTILO STREAMING ---
  Widget _buildScrollButton({required IconData icon, required VoidCallback onPressed}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF161616).withOpacity(0.85), // Fondo oscuro translúcido
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white10, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }
}
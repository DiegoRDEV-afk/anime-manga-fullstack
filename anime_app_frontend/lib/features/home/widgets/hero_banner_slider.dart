import 'dart:async'; // 1. Importa para el Timer
import 'package:flutter/material.dart';
import '../../../data/models/anime_model.dart';

class HeroBannerSlider extends StatefulWidget {
  final List<AnimeModel> items;
  const HeroBannerSlider({super.key, required this.items});

  @override
  State<HeroBannerSlider> createState() => _HeroBannerSliderState();
}

class _HeroBannerSliderState extends State<HeroBannerSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer; // 2. Variable para el temporizador

  @override
  void initState() {
    super.initState();
    _startTimer(); // 3. Iniciar ciclo al crear el widget
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_currentPage < widget.items.length - 1) {
        _pageController.nextPage(duration: const Duration(milliseconds: 800), curve: Curves.easeInOut);
      } else {
        _pageController.jumpToPage(0);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // 4. Limpiar para evitar fugas de memoria
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (widget.items.isEmpty) {
      return Container(height: 550, color: Colors.grey[900]);
    }

    return SizedBox(
      height: 550,
      width: size.width,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final anime = widget.items[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  // ... (Tu código de imagen y gradientes se mantiene igual)
                  anime.imagen != null
                      ? Image.network(
                          anime.bannerUrl ?? anime.imagen!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Colors.grey[900]),
                        )
                      : Container(color: Colors.grey[900]),
                  
                  // (Gradientes...)
                  Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0x66000000), Color(0xFF121212)], stops: [0.0, 0.5, 1.0]))),
                  Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.black54, Colors.transparent], stops: [0.0, 0.5]))),

                  // (Tu Padding con texto y botón se mantiene igual...)
                  Padding(
                    padding: const EdgeInsets.only(left: 48.0, right: 48.0, bottom: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(anime.titulo.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 12),
                        SizedBox(width: 450, child: Text(anime.sinopsis, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, height: 1.4))),
                        const SizedBox(height: 24),
                        ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text("COMENZAR A VER")),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // 5. Botones laterales
          Positioned(
            left: 10,
            top: 250,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
              onPressed: () {
                _pageController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.ease);
              },
            ),
          ),
          Positioned(
            right: 10,
            top: 250,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 30),
              onPressed: () {
                _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.ease);
              },
            ),
          ),

          // 6. Indicadores (Tu código existente se mantiene igual abajo)
          Positioned(
            bottom: 48,
            right: 48,
            child: Row(
              children: List.generate(
                widget.items.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(right: 8),
                  height: 4,
                  width: _currentPage == index ? 24 : 12,
                  decoration: BoxDecoration(color: _currentPage == index ? const Color(0xFF7C3AED) : Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
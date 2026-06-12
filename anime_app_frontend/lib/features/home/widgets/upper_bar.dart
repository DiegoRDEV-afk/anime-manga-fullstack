import 'dart:ui';
import 'package:flutter/material.dart';
import 'right_bar_actions.dart'; 

class UpperBar extends StatelessWidget implements PreferredSizeWidget {
  const UpperBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          height: preferredSize.height,
          decoration: BoxDecoration(
            color: const Color(0xFF121212).withOpacity(0.75),
            border: const Border(
              bottom: BorderSide(color: Colors.white10, width: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Stack( // 🟢 1. Cambiamos el Row principal por un Stack para superponer capas
              alignment: Alignment.center, // Fuerza a que todo lo que esté centrado use el eje real de la pantalla
              children: [
                
                // ================= CAPA 1: EXTREMOS (LOGO Y ACCIONES) =================
                // Usamos un Row con SpaceBetween pero SOLO para el logo y los iconos
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // IZQUIERDA: LOGO
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2E8F0), 
                        shape: BoxShape.circle,
                      ),
                    ),

                    // DERECHA: ACCIONES ANIMADAS
                    const RightBarActions(),
                  ],
                ),

                // ================= CAPA 2: EL CENTRO ABSOLUTO =================
                // Al estar dentro del Stack con alignment.center, este Row se clava en medio de la pantalla
                const Row(
                  mainAxisSize: MainAxisSize.min, // Importante para que no se expanda y rompa el Stack
                  children: [
                    _NavigationItem(title: "Inicio", isActive: true),
                    SizedBox(width: 32),
                    _NavigationItem(title: "Explorar"),
                    SizedBox(width: 32),
                    _NavigationItem(title: "Populares"),
                    SizedBox(width: 32),
                    _NavigationItem(title: "Novedades"),
                  ],
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70.0);
}

// Tu componente de items de navegación (Se mantiene igual)
class _NavigationItem extends StatelessWidget {
  final String title;
  final bool isActive;

  const _NavigationItem({
    required this.title,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
        fontSize: 14,
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
import 'dart:ui';
import 'package:flutter/material.dart';
import 'right_bar_actions.dart';

class UpperBar extends StatelessWidget implements PreferredSizeWidget {
  final int paginaActual;
  final Function(int) onPaginaChanged;

  const UpperBar({
    super.key,
    required this.paginaActual,
    required this.onPaginaChanged,
  });

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
            child: Stack(
              alignment: Alignment.center,
              children: [

                // CAPA 1: LOGO Y ACCIONES
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // LOGO
                    GestureDetector(
                      onTap: () => onPaginaChanged(0),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE2E8F0),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // ACCIONES
                    const RightBarActions(),
                  ],
                ),

                // CAPA 2: NAVEGACIÓN CENTRADA
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _NavigationItem(
                      title: 'Inicio',
                      isActive: paginaActual == 0,
                      onTap: () => onPaginaChanged(0),
                    ),
                    const SizedBox(width: 32),
                    _NavigationItem(
                      title: 'Explorar',
                      isActive: paginaActual == 1,
                      onTap: () => onPaginaChanged(1),
                    ),
                    const SizedBox(width: 32),
                    _NavigationItem(
                      title: 'Populares',
                      isActive: paginaActual == 2,
                      onTap: () => onPaginaChanged(2),
                    ),
                    const SizedBox(width: 32),
                    _NavigationItem(
                      title: 'Novedades',
                      isActive: paginaActual == 3,
                      onTap: () => onPaginaChanged(3),
                    ),
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

class _NavigationItem extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.title,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
          fontSize: 14,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
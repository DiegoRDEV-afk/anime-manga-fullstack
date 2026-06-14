import 'package:flutter/material.dart';
import '../home/screens/home_screen.dart';
import '../explore/screens/explore_screen.dart';
import '../../shared/widgets/upper_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _paginaActual = 0;

  final List<Widget> _paginas = const [
    HomePage(),
    ExploreScreen(),
    // PopularesScreen(), // después
    // NovedadesScreen(), // después
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // Página actual
          IndexedStack(
            index: _paginaActual,
            children: _paginas,
          ),

          // UpperBar flotante
          Positioned(
            top: 0, left: 0, right: 0,
            child: UpperBar(
              paginaActual: _paginaActual,
              onPaginaChanged: (index) {
                setState(() => _paginaActual = index);
              },
            ),
          ),
        ],
      ),
    );
  }
}     
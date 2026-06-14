import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/explore_controller.dart';
import '../../../shared/widgets/anime_card.dart';
import '../../../features/anime_detail/screens/anime_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExploreController>().cargarCatalogo();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── PANEL IZQUIERDO: FILTROS ─────────────────────────
          _PanelFiltros(searchController: _searchController),

          // ── PANEL DERECHO: RESULTADOS ────────────────────────
          const Expanded(child: _PanelResultados()),
        ],
      ),
    );
  }
}

// =======================================================
// PANEL DE FILTROS
// =======================================================
class _PanelFiltros extends StatelessWidget {
  final TextEditingController searchController;

  const _PanelFiltros({required this.searchController});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ExploreController>();

    return Container(
      width: 300,
      height: double.infinity,
      padding: const EdgeInsets.all(20),
      color: const Color(0xFF1A1A1A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          const Text(
            'EXPLORAR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height:50),

          // Buscar
          const Text('Buscar', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          TextField(
            controller: searchController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: controller.setQuery,
          ),

          const SizedBox(height: 16),

          // Estado
          const Text('Estados', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          _Dropdown(
            value: controller.estado,
            items: controller.estados,
            hint: 'Seleccionar',
            onChanged: controller.setEstado,
          ),

          const SizedBox(height: 16),

          // Tipo
          const Text('Tipos', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          _Dropdown(
            value: controller.tipo,
            items: controller.tipos,
            hint: 'Seleccionar',
            onChanged: controller.setTipo,
          ),

          const SizedBox(height: 16),

          // Géneros
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Géneros', style: TextStyle(color: Colors.white70, fontSize: 12)),
              if (controller.generos.isNotEmpty)
                GestureDetector(
                  onTap: () => controller.setEstado(null),
                  child: const Text('Limpiar', style: TextStyle(color: Color(0xFF7C3AED), fontSize: 11)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _GenerosSelector(
            generosDisponibles: controller.generosDisponibles,
            generosSeleccionados: controller.generos,
            onToggle: controller.toggleGenero,
          ),

          const SizedBox(height: 20),

          // Botón buscar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.estaCargando ? null : controller.buscar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Buscar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Botón limpiar
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                searchController.clear();
                controller.limpiarFiltros();
                controller.cargarCatalogo();
              },
              child: const Text(
                'Limpiar filtros',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =======================================================
// PANEL DE RESULTADOS
// =======================================================
class _PanelResultados extends StatelessWidget {
  const _PanelResultados();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ExploreController>();

    if (controller.estaCargando) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
      );
    }

    if (controller.mensajeError.isNotEmpty) {
      return Center(
        child: Text(
          controller.mensajeError,
          style: const TextStyle(color: Colors.white38),
        ),
      );
    }

    if (controller.resultados.isEmpty) {
      return const Center(
        child: Text('Sin resultados.', style: TextStyle(color: Colors.white38)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(top: 90, left: 40, right: 40, bottom: 30),
      /*padding: const EdgeInsets.all(40),*/
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: controller.resultados.length,
      itemBuilder: (context, index) {
        final anime = controller.resultados[index];
        return AnimeCard(
          anime: anime,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AnimeDetailScreen(animeId: anime.urlAnime ?? ''),
              ),
            );
          },
        );
      },
    );
  }
}

// =======================================================
// WIDGETS AUXILIARES
// =======================================================
class _Dropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String hint;
  final Function(String?) onChanged;

  const _Dropdown({
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint, style: const TextStyle(color: Colors.white38, fontSize: 13)),
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: const Color(0xFF1A1A1A),
        style: const TextStyle(color: Colors.white, fontSize: 13),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
        onChanged: onChanged,
        items: [
          DropdownMenuItem(
            value: null,
            child: Text(hint, style: const TextStyle(color: Colors.white38)),
          ),
          ...items.map((item) => DropdownMenuItem(value: item, child: Text(item))),
        ],
      ),
    );
  }
}

class _GenerosSelector extends StatelessWidget {
  final List<String> generosDisponibles;
  final List<String> generosSeleccionados;
  final Function(String) onToggle;

  const _GenerosSelector({
    required this.generosDisponibles,
    required this.generosSeleccionados,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: generosDisponibles.map((genero) {
        final seleccionado = generosSeleccionados.contains(genero);
        return GestureDetector(
          onTap: () => onToggle(genero),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: seleccionado ? const Color(0xFF7C3AED) : Colors.white10,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              genero,
              style: TextStyle(
                color: seleccionado ? Colors.white : Colors.white54,
                fontSize: 11,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
import 'package:flutter/material.dart';

class RightBarActions extends StatefulWidget {
  const RightBarActions({super.key});

  @override
  State<RightBarActions> createState() => _RightBarActionsState();
}

class _RightBarActionsState extends State<RightBarActions> with SingleTickerProviderStateMixin {
  bool _isSearching = false;

  List<String> recentSearches = [
    'One Piece',
    'Attack on Titan',
    'Demon Slayer',
    'My Hero Academia',
  ];

  final OverlayPortalController _overlayController = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250), // Velocidad de la animación
    );
    
    _widthAnimation = Tween<double>(begin: 88.0, end: 420.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCubic),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _activarBusqueda() {
    setState(() => _isSearching = true);
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _overlayController.show();
    });
  }

  void _desactivarBusqueda() async {
    _focusNode.unfocus();
    _overlayController.hide();
    await _animationController.reverse();
    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 CLAVE: El contenedor externo SIEMPRE mide 420px de ancho.
    // Esto actúa como un escudo invisible para que el centro de la barra no se mueva NADA.
    return SizedBox(
      width: 420,
      height: 40,
      child: Align(
        alignment: Alignment.centerRight,
        child: AnimatedBuilder(
          animation: _widthAnimation,
          builder: (context, child) {
            return SizedBox(
              width: _widthAnimation.value,
              child: _isSearching ? _buildSearchMode() : _buildNormalMode(),
            );
          },
        ),
      ),
    );
  }

  // === MODO NORMAL: Lupa y Campana ===
  Widget _buildNormalMode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Botón Lupa
        IconButton(
          onPressed: _activarBusqueda,
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.search,
            color: Colors.white.withOpacity(0.7),
            size: 22,
          ),
        ),
        const SizedBox(width: 24),
        // Botón Campana
        IconButton(
          onPressed: () {},
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.notifications_none,
            color: Colors.white.withOpacity(0.7),
            size: 22,
          ),
        ),
      ],
    );
  }

  // === MODO BÚSQUEDA: Input animado + Historial + Cancelar ===
  Widget _buildSearchMode() {
    return Row(
      children: [
        Expanded(
          child: CompositedTransformTarget(
            link: _layerLink,
            child: OverlayPortal(
              controller: _overlayController,
              overlayChildBuilder: (context) => CompositedTransformFollower(
                link: _layerLink,
                targetAnchor: Alignment.bottomLeft,
                followerAnchor: Alignment.topLeft,
                offset: const Offset(0, 8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: _buildRecentSearchMenu(context),
                ),
              ),
              child: _buildSearchTextField(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        FadeTransition(
          opacity: _fadeAnimation,
          child: TextButton(
            onPressed: _desactivarBusqueda,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchTextField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: TextField(
        focusNode: _focusNode,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: const InputDecoration(
          hintText: 'Encuentra lo que quieres buscar...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: Icon(Icons.search, color: Colors.grey, size: 18),
          suffixIcon: Icon(Icons.cancel, color: Colors.grey, size: 16),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildRecentSearchMenu(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    final width = renderBox?.size.width ?? 350;

    final animesMostar = recentSearches.take(4).toList();

    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 350,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 12, offset: const Offset(0, 6))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Busqueda reciente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                if(recentSearches.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() => recentSearches.clear());
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text('Borrar Todo', style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ],
            ),
            
            if(animesMostar.isNotEmpty)...[
              const SizedBox(height: 16),

              ...animesMostar.map((anime) => _buildRecentItem(anime)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItem(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 48,
            decoration: BoxDecoration(color: const Color(0xFFD9D9D9), borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
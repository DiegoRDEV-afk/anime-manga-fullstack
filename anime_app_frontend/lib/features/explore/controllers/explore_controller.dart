import 'package:flutter/material.dart';
import '../../../data/models/anime_model.dart';
import '../../../data/services/api_services.dart';

class ExploreController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<AnimeModel> _resultados = [];
  bool _estaCargando = false;
  String _mensajeError = '';

  // Filtros
  String _query = '';
  String? _estado;
  String? _tipo;
  List<String> _generos = [];

  List<AnimeModel> get resultados => _resultados;
  bool get estaCargando => _estaCargando;
  String get mensajeError => _mensajeError;
  String get query => _query;
  String? get estado => _estado;
  String? get tipo => _tipo;
  List<String> get generos => _generos;

  // Opciones de filtros
  final List<String> estados = ['En emisión', 'Finalizado', 'Próximamente'];
  final List<String> tipos = ['Anime', 'OVA', 'Película', 'Especial'];
  final List<String> generosDisponibles = [
    'Acción', 'Aventuras', 'Comedia', 'Drama', 'Fantasía',
    'Romance', 'Sci-Fi', 'Shounen', 'Seinen', 'Slice of Life',
    'Misterio', 'Terror', 'Superpoderes', 'Deportes', 'Musical',
  ];

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setEstado(String? value) {
    _estado = value;
    notifyListeners();
    buscar();
  }

  void setTipo(String? value) {
    _tipo = value;
    notifyListeners();
    buscar();
  }

  void toggleGenero(String genero) {
    if (_generos.contains(genero)) {
      _generos.remove(genero);
    } else {
      _generos.add(genero);
    }
    notifyListeners();
    buscar();
  }

  void limpiarFiltros() {
    _query = '';
    _estado = null;
    _tipo = null;
    _generos = [];
    _resultados = [];
    _mensajeError = '';
    notifyListeners();
  }

Future<void> buscar() async {
    _estaCargando = true;
    _mensajeError = '';
    notifyListeners();

    try {
      if (_query.isNotEmpty) {
        // Búsqueda por nombre
        _resultados = await _apiService.buscarAnime(_query);
      } else {
        // Búsqueda por filtros usando catálogo con género
        _resultados = await _apiService.getCatalogo(
          genero: _generos.isNotEmpty ? _generos.first.toLowerCase() : null,
        );
      }

      // Filtrar por tipo localmente
      if (_tipo != null && _tipo!.isNotEmpty) {
        _resultados = _resultados.where((a) =>
            a.tipo.toLowerCase().contains(_tipo!.toLowerCase())).toList();
      }

      // Filtrar por estado localmente
      if (_estado != null && _estado!.isNotEmpty) {
        final estadoMap = {
          'En emisión': 'en emision',
          'Finalizado': 'finalizado',
          'Próximamente': 'proximo',
        };
        final estadoBuscar = estadoMap[_estado!] ?? _estado!.toLowerCase();
        _resultados = _resultados.where((a) =>
            a.tipo.toLowerCase().contains(estadoBuscar)).toList();
      }

      // Filtrar resultados sin título o vacíos
      _resultados = _resultados
          .where((a) =>
              a.titulo.isNotEmpty &&
              a.titulo != 'Sin título' &&
              a.urlAnime != null &&
              a.urlAnime!.isNotEmpty)
          .toList();

      if (_resultados.isEmpty) {
        _mensajeError = 'No se encontraron resultados.';
      }
    } catch (e) {
      _mensajeError = 'Error de conexión con el servidor.';
    } finally {
      _estaCargando = false;
      notifyListeners();
    }
  }

  // Cargar catálogo inicial
  Future<void> cargarCatalogo() async {
    _estaCargando = true;
    _mensajeError = '';
    notifyListeners();

    try {
      _resultados = await _apiService.getCatalogo();
      // Filtrar resultados sin título o vacíos
      _resultados = _resultados
      .where((a) => 
          a.titulo.isNotEmpty && 
          a.titulo != 'Sin título' &&
          a.urlAnime != null &&
          a.urlAnime!.isNotEmpty)
      .toList();
      if (_resultados.isEmpty) {
        _mensajeError = 'No hay contenido disponible.';
      }
    } catch (e) {
      _mensajeError = 'Error de conexión con el servidor.';
    } finally {
      _estaCargando = false;
      notifyListeners();
    }
  }
}
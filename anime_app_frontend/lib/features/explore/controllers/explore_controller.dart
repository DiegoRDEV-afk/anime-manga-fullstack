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
  }

  void setTipo(String? value) {
    _tipo = value;
    notifyListeners();
  }

  void toggleGenero(String genero) {
    if (_generos.contains(genero)) {
      _generos.remove(genero);
    } else {
      _generos.add(genero);
    }
    notifyListeners();
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
    if (_query.isEmpty && _estado == null && _tipo == null && _generos.isEmpty) {
      _mensajeError = 'Ingresa al menos un filtro de búsqueda.';
      notifyListeners();
      return;
    }

    _estaCargando = true;
    _mensajeError = '';
    notifyListeners();

    try {
      _resultados = await _apiService.buscarAnime(_query);

      // Filtrar localmente por estado, tipo y géneros
      if (_estado != null) {
        _resultados = _resultados.where((a) =>
            a.tipo.toLowerCase().contains(_estado!.toLowerCase())).toList();
      }
      if (_tipo != null) {
        _resultados = _resultados.where((a) =>
            a.tipo.toLowerCase().contains(_tipo!.toLowerCase())).toList();
      }

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
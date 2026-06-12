import 'package:flutter/material.dart'; 
import '../../../data/models/anime_model.dart';
import '../../../data/services/api_services.dart';

class HomeController extends ChangeNotifier { 
  
  final ApiService _apiService = ApiService();

  List<AnimeModel> _animesTop = [];        // Hero banner (top 5)
  List<AnimeModel> _animesPopulares = [];  // Sección horizontal populares
  List<AnimeModel> _animesNovedades = [];  // Nuevos esta temporada
  List<AnimeModel> _ultimosEpisodios = []; // Nuevos episodios

  bool _estaCargando = false;
  String _mensageError = '';

  List<AnimeModel> get animesTop => _animesTop;
  List<AnimeModel> get animesPopulares => _animesPopulares;
  List<AnimeModel> get animesNovedades => _animesNovedades;
  List<AnimeModel> get ultimosEpisodios => _ultimosEpisodios;
  bool get estaCargando => _estaCargando;
  String get mensageError => _mensageError;

  Future<void> cargarContenidoHome() async {
    _estaCargando = true;
    _mensageError = '';
    notifyListeners();

    try {
      // Cargamos todo en paralelo para que sea más rápido
      final resultados = await Future.wait([
        _apiService.getTop(),
        _apiService.getPopulares(),
        _apiService.getNovedades(),
        _apiService.getUltimos(),
      ]);

      _animesTop        = resultados[0];
      _animesPopulares  = resultados[1];
      _animesNovedades  = resultados[2];
      _ultimosEpisodios = resultados[3];

      if (_animesTop.isEmpty && _animesPopulares.isEmpty) {
        _mensageError = 'No hay contenido disponible por el momento.';
      }
    } catch (e) {
      _mensageError = 'Error de conexión con el servidor.';
    } finally {
      _estaCargando = false;
      notifyListeners();
    }
  }
}
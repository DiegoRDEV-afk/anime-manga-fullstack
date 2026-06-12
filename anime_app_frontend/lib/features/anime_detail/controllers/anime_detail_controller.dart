import 'package:flutter/material.dart';
import '../../../data/models/anime_detail_model.dart';
import '../../../data/services/api_services.dart';

class AnimeDetailController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  AnimeDetailModel? animeDetalle;
  bool estaCargando = false;
  String? errorMensaje;

  Future<void> cargarDetalleAnime(String animeId) async {
    estaCargando = true;
    errorMensaje = null;
    notifyListeners();

    try {
      final resultado = await _apiService.obtenerDetallesAnime(animeId);
      if (resultado != null) {
        animeDetalle = resultado;
      } else {
        errorMensaje = 'No se encontraron detalles para este anime.';
      }
    } catch (e) {
      errorMensaje = 'Error al cargar el detalle del anime.';
    } finally {
      estaCargando = false;
      notifyListeners();
    }
  }

  void cargarDetalles(String animeId) {
    cargarDetalleAnime(animeId);
  }
}
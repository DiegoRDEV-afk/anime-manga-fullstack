import 'package:flutter/material.dart';
import '../../../data/models/anime_detail_model.dart';
import '../../../data/services/api_services.dart';

class AnimeDetailController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  AnimeDetailModel? animeDetalle;
  bool estaCargando = false;
  String? errorMensaje;

  String? urlTemporadaActual;
  bool cargandoEpisodios = false;

  Future<void> cargarDetalleAnime(String animeId) async {
    estaCargando = true;
    errorMensaje = null;
    notifyListeners();

    try {
      final resultado = await _apiService.obtenerDetallesAnime(animeId);

      if (resultado != null) {
        // ✅ Ordenar episodios iniciales ascendente
        final episodiosOrdenados = [...resultado.episodios]
          ..sort((a, b) => a.numero.compareTo(b.numero));

        animeDetalle = resultado.copyWith(episodios: episodiosOrdenados);
        urlTemporadaActual = animeId;
      } else {
        errorMensaje = 'No se encontraron detalles para este anime.';
      }
    } catch (e) {
      errorMensaje = 'Error al cargar el detalle del anime.';
      print("❌ Error en cargarDetalleAnime: $e");
    } finally {
      estaCargando = false;
      notifyListeners();
    }
  }

  // 🔄 Cambiar temporada actualizando solo los episodios
  Future<void> cambiarTemporada(String nuevaUrlTemporada) async {
    if (urlTemporadaActual == nuevaUrlTemporada || animeDetalle == null) return;

    urlTemporadaActual = nuevaUrlTemporada;
    cargandoEpisodios = true;
    notifyListeners();

    try {
      print("📡 Solicitando capítulos de la temporada: $nuevaUrlTemporada");

      final episodios =
          await _apiService.obtenerEpisodiosTemporada(nuevaUrlTemporada);

      // ✅ Ordenar ascendente por número de episodio
      episodios.sort((a, b) => a.numero.compareTo(b.numero));

      animeDetalle = animeDetalle!.copyWith(episodios: episodios);
    } catch (e) {
      print("❌ Error al cambiar temporada: $e");
    } finally {
      cargandoEpisodios = false;
      notifyListeners();
    }
  }

  void cargarDetalles(String animeId) {
    cargarDetalleAnime(animeId);
  }
}
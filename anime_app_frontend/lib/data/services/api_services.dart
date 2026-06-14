import 'package:dio/dio.dart';
import '../models/anime_model.dart';
import '../models/anime_detail_model.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://localhost:3000/api';

  // ─────────────────────────────────────────
  // BÚSQUEDA
  // ─────────────────────────────────────────
  Future<List<AnimeModel>> buscarAnime(String query, {String? provider}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/anime/search',
        queryParameters: {'q': query, if (provider != null) 'provider': provider},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> listaData = response.data['data']['results'];
        return listaData.map((e) => AnimeModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error en buscarAnime: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────
  // HOME
  // ─────────────────────────────────────────
  Future<Map<String, dynamic>> getHome() async {
    try {
      final response = await _dio.get('$_baseUrl/anime/home');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }
      return {};
    } catch (e) {
      print('❌ Error en getHome: $e');
      return {};
    }
  }

  Future<List<AnimeModel>> getTop() async {
    try {
      final home = await getHome();
      final List<dynamic> listaData = home['top5'] ?? [];
      return listaData.map((e) => AnimeModel.fromJson(e)).toList();
    } catch (e) {
      print('❌ Error en getTop: $e');
      return [];
    }
  }

  Future<List<AnimeModel>> getPopulares() async {
    try {
      final home = await getHome();
      final List<dynamic> listaData = home['populares'] ?? [];
      return listaData.map((e) => AnimeModel.fromJson(e)).toList();
    } catch (e) {
      print('❌ Error en getPopulares: $e');
      return [];
    }
  }

  Future<List<AnimeModel>> getUltimos() async {
    try {
      final home = await getHome();
      final List<dynamic> listaData = home['ultimosEpisodios'] ?? [];
      return listaData.map((e) => AnimeModel.fromJson(e)).toList();
    } catch (e) {
      print('❌ Error en getUltimos: $e');
      return [];
    }
  }

  Future<List<AnimeModel>> getNovedades() async {
    try {
      final response = await _dio.get('$_baseUrl/anime/novedades');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> listaData = response.data['data'];
        return listaData.map((e) => AnimeModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error en getNovedades: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────
  // DETALLE DEL ANIME
  // ─────────────────────────────────────────
  Future<Map<String, dynamic>> getAnimeInfo(String urlAnime) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/anime/info',
        queryParameters: {'url': urlAnime},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }
      return {};
    } catch (e) {
      print('❌ Error en getAnimeInfo: $e');
      return {};
    }
  }

  Future<AnimeDetailModel?> obtenerDetallesAnime(String urlAnime) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/anime/info',
        queryParameters: {'url': urlAnime},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return AnimeDetailModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('❌ Error en obtenerDetallesAnime: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────
  // VIDEO
  // ─────────────────────────────────────────
  Future<Map<String, dynamic>> getVideoUrl(String urlEpisodio) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/player/video',
        queryParameters: {'url': urlEpisodio},
      );
      if (response.statusCode == 200) return response.data;
      return {'success': false, 'error': 'Error del servidor'};
    } catch (e) {
      print('❌ Error en getVideoUrl: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<List<AnimeModel>> getCatalogo({int page = 1, String? genero}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/anime/catalog',
        queryParameters: {
          'page': page,
          if (genero != null) 'genre': genero,
          'provider': 'animeflv',
        },
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> listaData = response.data['data']['results'];
        return listaData.map((e) => AnimeModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error en getCatalogo: $e');
      return [];
    }
  }
}
import 'package:dio/dio.dart';
import '../models/anime_model.dart';
import '../models/anime_detail_model.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://localhost:3000/api';

  Future<List<AnimeModel>> buscarAnime(String query) async {
    try {
      final response = await _dio.get('$_baseUrl/buscar', queryParameters: {'q': query});
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> listaData = response.data['data'];
        return listaData.map((e) => AnimeModel.fromJson(e)).toList();
      } else {
        throw Exception('Error en la respuesta del servidor');
      }
    } catch (e) {
      print('❌ Error en buscarAnime: $e');
      return [];
    }
  }

  Future<List<AnimeModel>> getUltimos() async {
    try {
      final response = await _dio.get('$_baseUrl/ultimos');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> listaData = response.data['data'];
        return listaData.map((e) => AnimeModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error en getUltimos: $e');
      return [];
    }
  }

  Future<List<AnimeModel>> getPopulares() async {
    try {
      final response = await _dio.get('$_baseUrl/populares');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> listaData = response.data['data'];
        return listaData.map((e) => AnimeModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error en getPopulares: $e');
      return [];
    }
  }

  Future<List<AnimeModel>> getNovedades() async {
    try {
      final response = await _dio.get('$_baseUrl/novedades');
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

  Future<Map<String, dynamic>> getVideoUrl(String urlEpisodio) async {
    try {
      final response = await _dio.get('$_baseUrl/video', queryParameters: {'url': urlEpisodio});
      if (response.statusCode == 200) return response.data;
      return {'success': false, 'error': 'Error del servidor'};
    } catch (e) {
      print('❌ Error en getVideoUrl: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getAnimeInfo(String urlAnime) async {
    try {
      final response = await _dio.get('$_baseUrl/anime', queryParameters: {'url': urlAnime});
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }
      return {};
    } catch (e) {
      print('❌ Error en getAnimeInfo: $e');
      return {};
    }
  }
Future<List<AnimeModel>> getTop() async {
    try {
      final response = await _dio.get('$_baseUrl/populares/top');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> listaData = response.data['data'];
        return listaData.map((e) => AnimeModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error en getTop: $e');
      return [];
    }
  }

Future<AnimeDetailModel?> obtenerDetallesAnime(String urlAnime) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/anime',
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

} 

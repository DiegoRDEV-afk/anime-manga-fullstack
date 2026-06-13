class AnimeDetailModel {
  final String titulo;
  final String sinopsis;
  final String imagenPortada;
  final String imagenFondo;
  final double calificacion;
  final List<String> generos;
  final String estado;
  final String tipo;
  final int totalEpisodios;
  final List<EpisodioModel> episodios;

  AnimeDetailModel({
    required this.titulo,
    required this.sinopsis,
    required this.imagenPortada,
    required this.imagenFondo,
    required this.calificacion,
    required this.generos,
    required this.estado,
    required this.tipo,
    required this.totalEpisodios,
    required this.episodios,
  });

factory AnimeDetailModel.fromJson(Map<String, dynamic> json) {
    return AnimeDetailModel(
      titulo: json['titulo'] ?? json['title'] ?? '',
      sinopsis: json['sinopsis'] ?? json['description'] ?? '',
      imagenPortada: (json['imagenPortada'] ?? json['image'] ?? '').toString(),
      imagenFondo: (json['imagenFondo'] ?? json['image'] ?? '').toString(),
      calificacion: (json['calificacion'] ?? json['score'] ?? 0.0).toDouble(),
      estado: (json['estado'] ?? json['status'] ?? '').toString(),
      tipo: (json['tipo'] ?? json['type'] ?? '').toString(),
      totalEpisodios: (json['totalEpisodios'] ?? json['totalEpisodes'] ?? 0) as int,
      generos: (json['generos'] ?? json['genres'] ?? [])
          .map<String>((g) => g is String ? g : (g['name'] ?? '').toString())
          .toList(),
      episodios: (json['episodios'] ?? json['episodes'] ?? [])
          .map<EpisodioModel>((e) => EpisodioModel.fromJson(e))
          .toList(),
    );
  }

  String? get imagen => imagenPortada.isNotEmpty ? imagenPortada : null;
}

class EpisodioModel {
  final int numero;
  final String tituloEpisodio;
  final String miniatura;
  final String urlVer;

  EpisodioModel({
    required this.numero,
    required this.tituloEpisodio,
    required this.miniatura,
    required this.urlVer,
  });

factory EpisodioModel.fromJson(Map<String, dynamic> json) {
    return EpisodioModel(
      numero: json['numero'] ?? json['number'] ?? 0,
      tituloEpisodio: json['tituloEpisodio'] ?? json['title'] ?? '',
      miniatura: json['miniatura'] ?? json['thumbnail'] ?? '',
      urlVer: json['urlVer'] ?? json['url'] ?? '',
    );
  }
}
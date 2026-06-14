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
  final List<AnimeDetailEpisodeModel> episodios;
  final List<SeasonModel> seasons;

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
    required this.seasons,
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
          .map<AnimeDetailEpisodeModel>((e) => AnimeDetailEpisodeModel.fromJson(e))
          .toList(),
      seasons: (json['seasons'] ?? [])
          .map<SeasonModel>((s) => SeasonModel.fromJson(s))
          .toList(),
    );
  }

  AnimeDetailModel copyWith({
    List<AnimeDetailEpisodeModel>? episodios,
  }) {
    return AnimeDetailModel(
      titulo: titulo,
      sinopsis: sinopsis,
      imagenPortada: imagenPortada,
      imagenFondo: imagenFondo,
      calificacion: calificacion,
      generos: generos,
      estado: estado,
      tipo: tipo,
      totalEpisodios: totalEpisodios,
      episodios: episodios ?? this.episodios,
      seasons: seasons,
    );
  }
  String? get imagen => imagenPortada.isNotEmpty ? imagenPortada : null;
}

class AnimeDetailEpisodeModel {
  final int numero;
  final String tituloEpisodio;
  final String miniatura;
  final String urlVer;

  AnimeDetailEpisodeModel({
    required this.numero,
    required this.tituloEpisodio,
    required this.miniatura,
    required this.urlVer,
  });


factory AnimeDetailEpisodeModel.fromJson(Map<String, dynamic> json) {
    return AnimeDetailEpisodeModel(
      numero: json['numero'] ?? json['number'] ?? 0,
      tituloEpisodio: json['tituloEpisodio'] ?? json['title'] ?? '',
      miniatura: json['miniatura'] ?? json['thumbnail'] ?? '',
      urlVer: json['urlVer'] ?? json['url'] ?? '',
    );
  }
}

class SeasonModel {
  final String title;
  final String url;
  final int episodesCount;

  SeasonModel({
    required this.title,
    required this.url,
    required this.episodesCount,
  });

  factory SeasonModel.fromJson(Map<String, dynamic> json) {
    return SeasonModel(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      episodesCount: json['episodesCount'] ?? 0,
    );
  }
}
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
      titulo: json['titulo'] ?? '',
      sinopsis: json['sinopsis'] ?? '',
      imagenPortada: (json['imagenPortada'] ?? '').toString(),
      imagenFondo: (json['imagenFondo'] ?? '').toString(),
      calificacion: (json['calificacion'] ?? 0.0).toDouble(),
      generos: List<String>.from(json['generos'] ?? []),
      estado: (json['estado'] ?? '').toString(),
      tipo: (json['tipo'] ?? '').toString(),
      totalEpisodios: (json['totalEpisodios'] ?? 0) as int,
      episodios: (json['episodios'] as List?)
              ?.map((e) => EpisodioModel.fromJson(e))
              .toList() ?? [],
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
      numero: json['numero'] ?? 0,
      tituloEpisodio: json['tituloEpisodio'] ?? '',
      miniatura: json['miniatura'] ?? '',
      urlVer: json['urlVer'] ?? '',
    );
  }
}
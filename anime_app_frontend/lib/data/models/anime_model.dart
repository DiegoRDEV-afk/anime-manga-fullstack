class AnimeModel {
  // 1. Variables oficiales del proyecto
  final String titulo;
  final String tipo;
  final String sinopsis;
  final String? imagen; // Puede ser null si no hay portada
  final String urlAnime;
  final String? bannerUrl;


  // 2. Constructor de campos
  AnimeModel({
    required this.titulo,
    required this.tipo,
    required this.sinopsis,
    required this.imagen,
    required this.urlAnime,
    required this.bannerUrl
  });

  //3. Mapeador que transforma el JSON de la BD a un objeto de Dart
  factory AnimeModel.fromJson(Map<String, dynamic> json) {
    return AnimeModel(
      titulo: json['titulo'] ?? 'Sin título',
      tipo: json['tipo'] ?? 'TV',
      sinopsis: json['sinopsis'] ?? 'No hay sinopsis disponible para este anime.',
      imagen: json['imagen'],
      urlAnime: json['urlAnime'] ?? json['url_anime'] ?? '',
      bannerUrl: json['bannerUrl'],
    );
  }

  // Método opcional por si después necesitas hacer el camino inverso (objeto a JSON)
  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'tipo': tipo,
      'sinopsis': sinopsis,
      'imagen': imagen,
      'url_anime': urlAnime,
    };
  }
}

class EpisodioModel {
  final String titulo;
  final dynamic episodio;
  final String? imagen;
  final String? urlEpisodio;

  EpisodioModel({
    required this.titulo,
    this.episodio,
    this.imagen,
    this.urlEpisodio,
  });

  factory EpisodioModel.fromJson(Map<String, dynamic> json) {
    return EpisodioModel(
      titulo: json['titulo'] ?? '',
      episodio: json['episodio'],
      imagen: json['imagen'],
      urlEpisodio: json['urlEpisodio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'episodio': episodio,
      'imagen': imagen,
      'url_episodio': urlEpisodio,
    };
  }
}
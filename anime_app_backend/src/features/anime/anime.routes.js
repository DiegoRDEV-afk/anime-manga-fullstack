const express = require('express');
const router = express.Router();
const controller = require('./anime.controller');

// GET /api/anime/home
router.get('/home', controller.getHome);

// GET /api/anime/novedades
router.get('/novedades', controller.getNovedades);

// GET /api/anime/search?q=naruto&provider=animeflv
router.get('/search', controller.searchAnime);

// GET /api/anime/info?url=https://animeflv.net/anime/one-piece-tv
router.get('/info', controller.getAnimeInfo);

// GET /api/anime/episode?url=https://animeflv.net/ver/one-piece-tv-1
/*router.get('/episode', controller.getEpisodeLinks);*/
router.get('/video', controller.getEpisodeLinks);

// GET /api/anime/catalog?page=1&genre=accion&provider=animeflv
router.get('/catalog', controller.getCatalog);

// GET /api/anime/episodes?url=
router.get('/episodes', controller.getSeasonEpisodes);

module.exports = router;
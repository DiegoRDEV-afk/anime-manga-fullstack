const animeService = require('./anime.service');

async function getHome(req, res, next) {
    try {
        const result = await animeService.getHome();
        return res.json(result);
    } catch (error) {
        next(error);
    }
}

async function getNovedades(req, res, next) {
    try {
        const result = await animeService.getNovedades();
        return res.json(result);
    } catch (error) {
        next(error);
    }
}

async function searchAnime(req, res, next) {
    try {
        const { q, provider } = req.query;
        if (!q) return res.status(400).json({ success: false, message: 'Parámetro q requerido' });
        const result = await animeService.searchAnime(q, provider);
        return res.json(result);
    } catch (error) {
        next(error);
    }
}

async function getAnimeInfo(req, res, next) {
    try {
        const { url } = req.query;
        if (!url) return res.status(400).json({ success: false, message: 'Parámetro url requerido' });
        const result = await animeService.getAnimeInfo(url);
        return res.json(result);
    } catch (error) {
        next(error);
    }
}

async function getEpisodeLinks(req, res, next) {
    try {
        const { url, includeMega, excludeServers } = req.query;
        if (!url) return res.status(400).json({ success: false, message: 'Parámetro url requerido' });
        const result = await animeService.getEpisodeLinks(url, includeMega, excludeServers);
        return res.json(result);
    } catch (error) {
        next(error);
    }
}

async function getCatalog(req, res, next) {
    try {
        const { page, genre, provider } = req.query;
        const result = await animeService.getCatalog(page, genre, provider);
        return res.json(result);
    } catch (error) {
        next(error);
    }
}

module.exports = {
    getHome,
    getNovedades,
    searchAnime,
    getAnimeInfo,
    getEpisodeLinks,
    getCatalog,
};
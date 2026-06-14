const { URL } = require('node:url');
const axios = require('axios');
const { ApiError } = require('../../shared/utils/api-error');

const animeflvScraper = require('./scrapers/animeflv.scraper');
const jkanimeScraper = require('./scrapers/jkanime.scraper');
const tioanimetScraper = require('./scrapers/tioanime.scraper');
const monoschinoScraper = require('./scrapers/monoschino.scraper');
const hentailaScraper = require('./scrapers/hentaila.scraper');

const PROVIDERS = [
    {
        id: 'animeflv',
        label: 'AnimeFLV',
        domains: ['animeflv.net', 'www.animeflv.net', 'www4.animeflv.net'],
        service: animeflvScraper,
    },
    {
        id: 'jkanime',
        label: 'JKAnime',
        domains: ['jkanime.net', 'www.jkanime.net'],
        service: jkanimeScraper,
    },
    {
        id: 'tioanime',
        label: 'TioAnime',
        domains: ['tioanime.com', 'www.tioanime.com'],
        service: tioanimetScraper,
    },
    {
        id: 'monoschino',
        label: 'MonosChino',
        domains: ['monoschino2.com', 'www.monoschino2.com'],
        service: monoschinoScraper,
    },
    {
        id: 'hentaila',
        label: 'HentaiLA',
        domains: ['hentaila.com', 'www.hentaila.com'],
        service: hentailaScraper,
        adult: true,
    },
];

// ─────────────────────────────────────────
// UTILIDADES
// ─────────────────────────────────────────

function normalizeDomain(value) {
    if (!value || typeof value !== 'string') return null;
    const trimmed = value.trim().toLowerCase();
    try {
        if (trimmed.includes('://')) return new URL(trimmed).hostname.toLowerCase();
        return new URL(`https://${trimmed}`).hostname.toLowerCase();
    } catch {
        return trimmed.split('/')[0];
    }
}

function findProviderByDomain(domainCandidate) {
    const domain = normalizeDomain(domainCandidate);
    if (!domain) return null;
    return PROVIDERS.find(p => p.domains.some(d => domain === d || domain.endsWith(`.${d}`))) || null;
}

function findProviderById(providerId) {
    if (!providerId || typeof providerId !== 'string') return null;
    return PROVIDERS.find(p => p.id === providerId.trim().toLowerCase()) || null;
}

function findProviderForUrl(urlCandidate) {
    if (!urlCandidate || typeof urlCandidate !== 'string') return null;
    try {
        const host = new URL(urlCandidate).hostname;
        return findProviderByDomain(host);
    } catch { return null; }
}

// ─────────────────────────────────────────
// ANILIST — ENRIQUECIMIENTO DE METADATOS
// ─────────────────────────────────────────

const ANILIST_API = 'https://graphql.anilist.co';

const ANILIST_QUERY = `
query ($search: String) {
  Media(search: $search, type: ANIME) {
    title {
      romaji
      english
      native
    }
    coverImage {
      extraLarge
      large
    }
    bannerImage
    description(asHtml: false)
    genres
    averageScore
    status
    episodes
    format
  }
}
`;

/**
 * Busca metadatos enriquecidos en AniList por título.
 * Retorna null si no encuentra nada o si falla (nunca rompe el flujo principal).
 */
async function fetchAniListMetadata(titulo) {
    if (!titulo || typeof titulo !== 'string') return null;

    // Limpiamos el título para mejorar el match:
    // quitamos sufijos de temporada comunes antes de buscar
    const cleanTitle = titulo
        .replace(/season\s*\d+/gi, '')
        .replace(/\d+(st|nd|rd|th)\s*season/gi, '')
        .replace(/parte?\s*\d+/gi, '')
        .trim();

    try {
        const response = await axios.post(
            ANILIST_API,
            {
                query: ANILIST_QUERY,
                variables: { search: cleanTitle },
            },
            {
                timeout: 8000,
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                },
            }
        );

        const media = response?.data?.data?.Media;
        if (!media) return null;

        // Normalizamos el estado al español
        const estadoMap = {
            FINISHED: 'Finalizado',
            RELEASING: 'En emisión',
            NOT_YET_RELEASED: 'Próximamente',
            CANCELLED: 'Cancelado',
            HIATUS: 'En pausa',
        };

        // Normalizamos el formato al español
        const formatoMap = {
            TV: 'Serie',
            TV_SHORT: 'Serie Corta',
            MOVIE: 'Película',
            SPECIAL: 'Especial',
            OVA: 'OVA',
            ONA: 'ONA',
            MUSIC: 'Musical',
        };

        return {
            imagenPortada: media.coverImage?.extraLarge || media.coverImage?.large || null,
            imagenFondo: media.bannerImage || media.coverImage?.extraLarge || null,
            sinopsis: media.description || null,
            generos: media.genres || [],
            calificacion: media.averageScore ? media.averageScore / 10 : 0.0,
            estado: estadoMap[media.status] || media.status || null,
            tipo: formatoMap[media.format] || media.format || null,
            totalEpisodiosAniList: media.episodes || null,
        };
    } catch (error) {
        console.warn(`⚠️ [AniList] Error al buscar "${cleanTitle}":`, error.message);
        return null;
    }
}

// ─────────────────────────────────────────
// VERIFICADOR DE ENLACES EN TIEMPO REAL
// ─────────────────────────────────────────

async function isLinkAlive(url) {
    if (!url || typeof url !== 'string' || !url.startsWith('http')) return false;

    const headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    };

    try {
        const response = await axios.head(url, { timeout: 2000, headers });
        return response.status >= 200 && response.status < 400;
    } catch {
        try {
            const response = await axios.get(url, { timeout: 2000, headers, maxContentLength: 500 });
            return response.status >= 200 && response.status < 400;
        } catch {
            return false;
        }
    }
}

// ─────────────────────────────────────────
// HOME
// ─────────────────────────────────────────

async function getHome() {
    return animeflvScraper.getHome();
}

async function getNovedades() {
    return animeflvScraper.getNovedades();
}

// ─────────────────────────────────────────
// BÚSQUEDA MULTI-PROVEEDOR
// ─────────────────────────────────────────

async function searchAnime(query, providerIdOrDomain) {
    const forcedProvider = findProviderByDomain(providerIdOrDomain) || findProviderById(providerIdOrDomain);

    if (forcedProvider) {
        const result = await forcedProvider.service.searchAnime(query, forcedProvider.domains[0]);
        return { ...result, source: result?.source || forcedProvider.id };
    }

    const activeProviders = PROVIDERS.filter(p => !p.adult);
    const searchPromises = activeProviders.map(async (provider) => {
        try {
            const result = await provider.service.searchAnime(query, provider.domains[0]);
            const results = result?.data?.results || [];
            results.forEach(item => { item.provider = provider.label; });
            return { success: true, providerId: provider.id, results };
        } catch (error) {
            console.warn(`[SEARCH] Error en proveedor ${provider.id}:`, error.message);
            return { success: false, providerId: provider.id };
        }
    });

    const searchResults = await Promise.all(searchPromises);
    const allResults = searchResults.filter(r => r.success && r.results.length > 0).flatMap(r => r.results);

    return {
        success: true,
        source: 'Multi',
        data: { results: allResults, count: allResults.length },
    };
}

// ─────────────────────────────────────────
// DETALLE DEL ANIME (con merge AniList)
// ─────────────────────────────────────────

async function getAnimeInfo(urlCandidate) {
    const provider = findProviderForUrl(urlCandidate) || PROVIDERS[0];
    if (!provider) throw new ApiError(400, 'Proveedor no soportado');

    // 🚀 Llamadas en paralelo: AnimeFLV + AniList al mismo tiempo
    const [animeflvResult, anilistData] = await Promise.all([
        provider.service.getAnimeInfo(urlCandidate),
        // Extraemos el título del slug de la URL para buscar en AniList
        // antes de tener el resultado de AnimeFLV (usando el slug como query inicial)
        (async () => {
            try {
                const parsed = new URL(urlCandidate);
                const segments = parsed.pathname.split('/').filter(Boolean);
                const slug = segments[1] || segments[0] || '';
                const queryFromSlug = slug.replace(/-/g, ' ').trim();
                return await fetchAniListMetadata(queryFromSlug);
            } catch {
                return null;
            }
        })(),
    ]);

    const base = animeflvResult?.data || {};

    // Si AniList devolvió datos, los usamos para enriquecer.
    // AnimeFLV siempre gana en episodios y seasons (su razón de ser).
    // AniList gana en todo lo visual y de metadatos.
    const merged = {
        ...base,
        // ── Metadatos enriquecidos de AniList ──────────────────
        imagenPortada:  anilistData?.imagenPortada  || base.imagenPortada  || null,
        imagenFondo:    anilistData?.imagenFondo    || base.imagenFondo    || null,
        sinopsis:       anilistData?.sinopsis       || base.sinopsis       || null,
        generos:        anilistData?.generos?.length
                            ? anilistData.generos
                            : base.generos          || [],
        calificacion:   anilistData?.calificacion   ?? base.calificacion   ?? 0.0,
        estado:         anilistData?.estado         || base.estado         || null,
        tipo:           anilistData?.tipo           || base.tipo           || null,

        // ── Episodios y seasons siempre de AnimeFLV ────────────
        episodios:      base.episodios  || [],
        seasons:        base.seasons    || [],
        totalEpisodios: base.totalEpisodios || anilistData?.totalEpisodiosAniList || 0,
    };

    console.log(`✅ [AniList] Merge completado para "${base.titulo}" — portada: ${anilistData ? 'HD' : 'AnimeFLV fallback'}`);

    return {
        ...animeflvResult,
        data: merged,
        source: animeflvResult?.source || provider.id,
    };
}

// ─────────────────────────────────────────
// LINKS DEL EPISODIO (Optimizados y Verificados)
// ─────────────────────────────────────────

async function getEpisodeLinks(urlCandidate, includeMega, excludeServers) {
    let provider = findProviderForUrl(urlCandidate) || PROVIDERS[0];
    if (!provider) throw new ApiError(400, 'Proveedor no soportado');

    let result = null;

    // 🚀 INTERCEPTOR INTELIGENTE: Si viene de AnimeFLV, saltamos al espejo Full HD de TioAnime
    if (provider.id === 'animeflv') {
        try {
            const urlParts = urlCandidate.split('/');
            const episodeSlug = urlParts[urlParts.length - 1];
            const tioAnimeMirrorUrl = `https://tioanime.com/ver/${episodeSlug}`;
            const targetProvider = findProviderById('tioanime');

            if (targetProvider) {
                console.log(`✨ [1080p Engine] Intentando espejo en TioAnime: ${tioAnimeMirrorUrl}`);
                const mirrorResult = await targetProvider.service.getEpisodeLinks(tioAnimeMirrorUrl, includeMega, excludeServers);

                if (mirrorResult?.data?.servers?.sub?.length > 0) {
                    result = { ...mirrorResult, source: 'tioanime' };
                    console.log('🟢 [1080p Engine] Servidores Full HD obtenidos exitosamente.');
                }
            }
        } catch (mirrorError) {
            console.warn('⚠️ [1080p Engine] El espejo falló. Recurriendo a la fuente original.');
        }
    }

    if (!result) {
        const rawResult = await provider.service.getEpisodeLinks(urlCandidate, includeMega, excludeServers);
        result = { ...rawResult, source: rawResult?.source || provider.id };
    }

    // 🛡️ MOTOR DE SUPERVIVENCIA: Filtrar enlaces caídos
    if (result?.data?.servers?.sub?.length > 0) {
        console.log('🔍 [Link Checker] Purgando enlaces rotos de la respuesta...');

        let validServers = [];
        const topServersToTest = result.data.servers.sub.slice(0, 4);

        for (const srv of topServersToTest) {
            const lowerServer = srv.server.toLowerCase();
            if (lowerServer.includes('player') || lowerServer.includes('embed') || srv.url.includes('iframe')) {
                validServers.push(srv);
                continue;
            }

            const alive = await isLinkAlive(srv.url);
            if (alive) {
                validServers.push(srv);
                if (validServers.length === 1) break;
            } else {
                console.warn(`❌ [Link Checker] Servidor caído removido: [${srv.server}]`);
            }
        }

        if (validServers.length === 0) {
            validServers = result.data.servers.sub;
        } else {
            const nonTestedServers = result.data.servers.sub.slice(topServersToTest.length);
            validServers = [...validServers, ...nonTestedServers];
        }

        result.data.servers.sub = validServers;
        if (result.data.streamLinks?.SUB) {
            result.data.streamLinks.SUB = validServers;
        }
    }

    return result;
}

// ─────────────────────────────────────────
// CATÁLOGO
// ─────────────────────────────────────────

async function getCatalog(page, genre, providerId) {
    const provider = findProviderById(providerId) || PROVIDERS[0];
    if (provider.service.getCatalog) {
        return provider.service.getCatalog(page, genre);
    }
    throw new ApiError(400, 'Este proveedor no soporta catálogo');
}

// ─────────────────────────────────────────
// EPISODIOS DE TEMPORADAS
// ─────────────────────────────────────────

const getSeasonEpisodes = async (url) => {
    console.log('🚀 getSeasonEpisodes iniciado para:', url);

    const animeInfo = await animeflvScraper.getAnimeInfo(url);

    console.log('✅ getAnimeInfo terminó');

    const episodios = animeInfo?.data?.episodios || [];

    console.log('📺 Episodios encontrados:', episodios.length);

    return episodios;
};

module.exports = {
    getHome,
    getNovedades,
    searchAnime,
    getAnimeInfo,
    getEpisodeLinks,
    getCatalog,
    getSeasonEpisodes,
    PROVIDERS,
};
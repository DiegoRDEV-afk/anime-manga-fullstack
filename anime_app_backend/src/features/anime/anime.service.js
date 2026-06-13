const { URL } = require('node:url');
const axios = require('axios'); // 🟢 Requerido para verificar los enlaces en vivo
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

// 🟢 VERIFICADOR DE ENLACES EN TIEMPO REAL
async function isLinkAlive(url) {
    if (!url || typeof url !== 'string' || !url.startsWith('http')) return false;
    
    const headers = { 
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' 
    };

    try {
        // Intento veloz con HEAD (no descarga peso, solo lee headers)
        const response = await axios.head(url, { timeout: 2000, headers });
        return response.status >= 200 && response.status < 400;
    } catch (error) {
        try {
            // Intento de respaldo con GET corto por si el servidor rechaza peticiones HEAD
            const response = await axios.get(url, { timeout: 2000, headers, maxContentLength: 500 });
            return response.status >= 200 && response.status < 400;
        } catch (innerError) {
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
// DETALLE DEL ANIME
// ─────────────────────────────────────────

async function getAnimeInfo(urlCandidate) {
    const provider = findProviderForUrl(urlCandidate) || PROVIDERS[0];
    if (!provider) throw new ApiError(400, 'Proveedor no soportado');
    const result = await provider.service.getAnimeInfo(urlCandidate);
    return { ...result, source: result?.source || provider.id };
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
                
                if (mirrorResult && mirrorResult.data && mirrorResult.data.servers && mirrorResult.data.servers.sub.length > 0) {
                    result = { ...mirrorResult, source: 'tioanime' };
                    console.log('🟢 [1080p Engine] Servidores Full HD obtenidos exitosamente.');
                }
            }
        } catch (mirrorError) {
            console.warn('⚠️ [1080p Engine] El espejo falló. Recurriendo a la fuente original.');
        }
    }

    // Si no se originó en AnimeFLV o el espejo falló, extraemos de la fuente por defecto
    if (!result) {
        const rawResult = await provider.service.getEpisodeLinks(urlCandidate, includeMega, excludeServers);
        result = { ...rawResult, source: rawResult?.source || provider.id };
    }

    // 🛡️ MOTOR DE SUPERVIVENCIA: Filtrar enlaces caídos en la punta del array para Flutter
    if (result && result.data && result.data.servers && result.data.servers.sub.length > 0) {
        console.log(`🔍 [Link Checker] Purgando enlaces rotos de la respuesta...`);
        
        let validServers = [];
        // Validamos únicamente el top 4 de los mejores servidores para no retrasar la API
        const topServersToTest = result.data.servers.sub.slice(0, 4);

        for (const srv of topServersToTest) {
            const lowerServer = srv.server.toLowerCase();
            // Le damos pase directo a reproductores locales incrustados complejos que no admiten ping directo
            if (lowerServer.includes('player') || lowerServer.includes('embed') || srv.url.includes('iframe')) {
                validServers.push(srv);
                continue;
            }

            const alive = await isLinkAlive(srv.url);
            if (alive) {
                validServers.push(srv);
                // Si el servidor número 1 (el mejor en 1080p) está vivo, rompemos el bucle para responder al instante
                if (validServers.length === 1) break;
            } else {
                console.warn(`❌ [Link Checker] Servidor caído removido: [${srv.server}]`);
            }
        }

        // Reconstrucción final del catálogo de servidores
        if (validServers.length === 0) {
            // Si por alguna razón extrema todo falló, dejamos la lista original intacta como último recurso
            validServers = result.data.servers.sub;
        } else {
            // Adjuntamos el resto de los servidores intermedios que no probamos
            const nonTestedServers = result.data.servers.sub.slice(topServersToTest.length);
            validServers = [...validServers, ...nonTestedServers];
        }

        // Sincronizamos las propiedades de respuesta para Flutter
        result.data.servers.sub = validServers;
        if (result.data.streamLinks && result.data.streamLinks.SUB) {
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

module.exports = {
    getHome,
    getNovedades,
    searchAnime,
    getAnimeInfo,
    getEpisodeLinks,
    getCatalog,
    PROVIDERS,
};
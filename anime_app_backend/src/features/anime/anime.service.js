const { URL } = require('node:url');
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

    // Búsqueda en paralelo en todos los proveedores (excepto adult)
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
// LINKS DEL EPISODIO
// ─────────────────────────────────────────

async function getEpisodeLinks(urlCandidate, includeMega, excludeServers) {
    const provider = findProviderForUrl(urlCandidate) || PROVIDERS[0];
    if (!provider) throw new ApiError(400, 'Proveedor no soportado');
    const result = await provider.service.getEpisodeLinks(urlCandidate, includeMega, excludeServers);
    return { ...result, source: result?.source || provider.id };
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
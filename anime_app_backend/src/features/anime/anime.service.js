const { URL } = require("node:url");

// 1. Importamos tus scrapers individuales
const animeflvScraper = require('./scrapers/animeflv.scraper');
const animev1Scraper = require('./scrapers/animev1.scraper');
const hentailaScraper = require('./scrapers/hentaila.scraper');
const jkanimeScraper = require('./scrapers/jkanime.scraper');
const monoschinoScraper = require('./scrapers/monoschino.scraper');
const tioanimeScraper = require('./scrapers/tioanime.scraper');

// 2. Mapeamos los proveedores con sus dominios y sus respectivos scrapers
const PROVIDERS = [
  {
    id: "animeflv",
    label: "AnimeFLV",
    domains: ["animeflv.net", "www.animeflv.net", "www4.animeflv.net"],
    scraper: animeflvScraper,
  },
  {
    id: "animev1",
    label: "AnimeAV1",
    domains: ["animeav1.com", "www.animeav1.com"],
    scraper: animev1Scraper,
  },
  {
    id: "jkanime",
    label: "JKAnime",
    domains: ["jkanime.net", "www.jkanime.net"],
    scraper: jkanimeScraper,
  },
  {
    id: "hentaila",
    label: "HentaiLA",
    domains: ["hentaila.com", "www.hentaila.com"],
    scraper: hentailaScraper,
  },
  {
    id: "tioanime",
    label: "TioAnime",
    domains: ["tioanime.com", "www.tioanime.com"],
    scraper: tioanimeScraper,
  },
  {
    id: "monoschino",
    label: "MonosChinos",
    domains: ["monoschinos2.com", "www.monoschinos2.com"],
    scraper: monoschinoScraper,
  },
];

// ==========================================
// FUNCIONES METODOLÓGICAS (Normalizar y buscar dominios)
// ==========================================

function normalizeDomain(value) {
  if (!value || typeof value !== "string") return null;
  const trimmed = value.trim().toLowerCase();
  if (!trimmed) return null;

  try {
    if (trimmed.includes("://")) {
      return new URL(trimmed).hostname.toLowerCase();
    }
    return new URL(`https://${trimmed}`).hostname.toLowerCase();
  } catch (_error) {
    return trimmed.split("/")[0];
  }
}

function domainMatches(domain, candidate) {
  if (!domain || !candidate) return false;
  return domain === candidate || domain.endsWith(`.${candidate}`);
}

function findProviderByDomain(domainCandidate) {
  const domain = normalizeDomain(domainCandidate);
  if (!domain) return null;
  return PROVIDERS.find((p) => p.domains.some((cand) => domainMatches(domain, cand))) || null;
}

function findProviderById(providerId) {
  if (!providerId || typeof providerId !== "string") return null;
  const normalized = providerId.trim().toLowerCase();
  return PROVIDERS.find((p) => p.id === normalized) || null;
}

function findProviderForUrl(urlCandidate) {
  if (!urlCandidate || typeof urlCandidate !== "string") return null;
  try {
    const host = new URL(urlCandidate).hostname;
    return findProviderByDomain(host);
  } catch (_error) {
    return null;
  }
}

// ==========================================
// FUNCIONES CORE DEL SERVICIO
// ==========================================

/**
 * Busca animes en un proveedor específico o en todos en paralelo
 */
async function searchAnime(query, providerOrDomain) {
  // Buscamos si el usuario forzó un proveedor (ya sea por ID como 'animeflv' o por dominio)
  const forcedProvider = findProviderByDomain(providerOrDomain) || findProviderById(providerOrDomain);

  if (forcedProvider) {
    const result = await forcedProvider.scraper.search(query);
    return {
      success: true,
      source: forcedProvider.id,
      providerLabel: forcedProvider.label,
      data: { results: result, count: result.length }
    };
  }

  // SI NO HAY PROVEEDOR FORZADO: Búsqueda unificada en paralelo en TODOS los proveedores
  const searchPromises = PROVIDERS.map(async (provider) => {
    try {
      const results = await provider.scraper.search(query);
      return {
        success: true,
        providerId: provider.id,
        providerLabel: provider.label,
        results: results || []
      };
    } catch (error) {
      console.warn(`[SEARCH] Error en proveedor ${provider.id}:`, error.message);
      return { success: false, providerId: provider.id, results: [] };
    }
  });

  const searchResults = await Promise.all(searchPromises);
  const allResults = [];

  for (const res of searchResults) {
    if (res.success && res.results.length > 0) {
      // Inyectamos qué proveedor trajo este anime para que Flutter lo sepa
      res.results.forEach(item => item.provider = res.providerLabel);
      allResults.push(...res.results);
    }
  }

  if (allResults.length > 0) {
    return {
      success: true,
      source: "Multi",
      data: { results: allResults, count: allResults.length }
    };
  }

  throw new Error("No se encontraron resultados en ningún proveedor o los servidores están caídos.");
}

/**
 * Obtiene la información detallada de un anime usando su URL
 */
async function getAnimeInfo(urlCandidate) {
  const provider = findProviderForUrl(urlCandidate) || PROVIDERS[0];
  if (!provider) throw new Error("Proveedor no soportado");

  // Redirecciona al método getAnimeInfo del scraper correspondiente
  const result = await provider.scraper.getAnimeInfo(urlCandidate);
  return {
    success: true,
    source: provider.id,
    data: result
  };
}

/**
 * Obtiene los enlaces de reproducción de un episodio usando su URL
 */
async function getEpisodeLinks(urlCandidate, includeMega, excludeServers) {
  const provider = findProviderForUrl(urlCandidate) || PROVIDERS[0];
  if (!provider) throw new Error("Proveedor no soportado");

  // Redirecciona al método getEpisodeLinks del scraper correspondiente
  const result = await provider.scraper.getEpisodeLinks(urlCandidate, includeMega, excludeServers);
  return {
    success: true,
    source: provider.id,
    data: result
  };
}

module.exports = {
  searchAnime,
  getAnimeInfo,
  getEpisodeLinks,
};
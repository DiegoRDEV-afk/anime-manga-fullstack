const axios = require('axios');
const cheerio = require('cheerio');
const vm = require('node:vm');
const { URL } = require('node:url');
const { ApiError } = require('../../../shared/utils/api-error');
const { getBrowser } = require('../../../shared/utils/browser');

const DEFAULT_DOMAIN = 'animeflv.net';

const HTTP_HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'es-ES,es;q=0.9,en;q=0.8',
};

async function fetchHtmlWithPuppeteer(url) {
    const browser = await getBrowser();
    const page = await browser.newPage();
    await page.setUserAgent(HTTP_HEADERS['User-Agent']);
    await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 30000 });
    let retries = 0;
    while (retries < 10) {
        const content = await page.content();
        const $ = cheerio.load(content);
        const bodyText = $('body').text().trim();
        if (bodyText.length > 500) break;
        await new Promise(r => setTimeout(r, 2000));
        retries++;
    }
    const content = await page.content();
    await page.close();
    return content;
}

async function fetchHtml(url) {
    try {
        const timeout = Number(process.env.REQUEST_TIMEOUT_MS || 15000);
        const response = await axios.get(url, {
            timeout,
            headers: HTTP_HEADERS,
            maxRedirects: 5,
            validateStatus: (status) => status >= 200 && status < 400,
        });
        return response.data;
    } catch (error) {
        try {
            console.log(`fetchHtml: intentando con puppeteer para ${url}`);
            return await fetchHtmlWithPuppeteer(url);
        } catch {
            throw new ApiError(500, 'No se pudo obtener contenido desde AnimeFLV', error.message);
        }
    }
}

function resolveAbsoluteUrl(urlCandidate, domain = DEFAULT_DOMAIN) {
    if (!urlCandidate || typeof urlCandidate !== 'string') return null;
    try {
        return new URL(urlCandidate, `https://${domain}`).toString();
    } catch { return null; }
}

function parseNumber(value) {
    if (typeof value === 'number' && Number.isFinite(value)) return value;
    const converted = Number(value);
    return Number.isFinite(converted) ? converted : null;
}

function normalizeToken(value) {
    return (value || '').toString().toLowerCase().replace(/[^a-z0-9]+/g, '').trim();
}

function normalizeServerName(serverName, url) {
    if (serverName && typeof serverName === 'string') {
        const token = normalizeToken(serverName);
        if (token) return { name: serverName.trim(), token };
    }
    try {
        const host = new URL(url).hostname.replace(/^www\./, '');
        return { name: host, token: normalizeToken(host) };
    } catch { return { name: 'Unknown', token: 'unknown' }; }
}

function normalizeVariantKey(value) {
    const normalized = normalizeToken(value);
    if (!normalized) return 'SUB';
    if (normalized.includes('sub') || normalized.includes('jap') || normalized.includes('jp')) return 'SUB';
    return 'DUB';
}

function pushDeduped(target, link) {
    if (!link || !link.url) return;
    if (target.some((item) => item.url === link.url)) return;
    target.push(link);
}

function buildExcludedTokens(includeMega, excludeServersRaw) {
    const excluded = new Set();
    const raw = typeof excludeServersRaw === 'string' ? excludeServersRaw : '';
    for (const part of raw.split(',')) {
        const token = normalizeToken(part);
        if (token) excluded.add(token);
    }
    if (!includeMega) excluded.add('mega');
    return excluded;
}

function filterLinksByServers(links, excludedTokens) {
    return links.filter((link) => {
        const token = normalizeToken(link.token || link.server);
        if (!token) return true;
        if (excludedTokens.has(token)) return false;
        if (token.includes('mega') && excludedTokens.has('mega')) return false;
        return true;
    });
}

function sanitizeLinksForResponse(links) {
    return links.map((link) => {
        const result = { server: link.server, url: link.url };
        if (link.quality) result.quality = link.quality;
        return result;
    });
}

function extractBalancedSection(text, startIndex, openChar, closeChar) {
    let depth = 0, activeQuote = '', escaped = false;
    for (let i = startIndex; i < text.length; i++) {
        const char = text[i];
        if (activeQuote) {
            if (escaped) { escaped = false; continue; }
            if (char === '\\') { escaped = true; continue; }
            if (char === activeQuote) activeQuote = '';
            continue;
        }
        if (char === '"' || char === "'" || char === '`') { activeQuote = char; continue; }
        if (char === openChar) depth++;
        if (char === closeChar) { depth--; if (depth === 0) return text.slice(startIndex, i + 1); }
    }
    return null;
}

function safeEvaluate(expression) {
    try {
        const context = Object.create(null);
        return vm.runInNewContext(expression, context, { timeout: 1000, displayErrors: false });
    } catch { return null; }
}

function extractVarLiteral(html, varName) {
    const marker = `var ${varName}`;
    const startIndex = html.indexOf(marker);
    if (startIndex === -1) return null;
    const equalsIndex = html.indexOf('=', startIndex);
    if (equalsIndex === -1) return null;
    const slice = html.slice(equalsIndex + 1);
    const firstBracketIndex = slice.search(/[\[{]/);
    if (firstBracketIndex === -1) return null;
    const openChar = slice[firstBracketIndex];
    const closeChar = openChar === '{' ? '}' : ']';
    return extractBalancedSection(slice, firstBracketIndex, openChar, closeChar);
}

function tryDecodeBase64(value) {
    if (!value || typeof value !== 'string') return null;
    try {
        if (/^[A-Za-z0-9+/=]+$/.test(value) && value.length > 10) {
            const decoded = Buffer.from(value, 'base64').toString('utf8');
            if (decoded.startsWith('http://') || decoded.startsWith('https://')) return decoded;
        }
    } catch { }
    return null;
}

function decodeUrlEscapes(value) {
    if (!value || typeof value !== 'string') return value;
    return value.replace(/\\u0026/g, '&').replace(/\\u003A/g, ':').replace(/\\u002F/g, '/').replace(/&amp;/g, '&');
}

function buildLinkRecord(serverName, url, quality) {
    if (!url) return null;
    const server = normalizeServerName(serverName, url);
    return { server: server.name, token: server.token, url, quality: quality || null };
}

function parseEpisodeNumberFromUrl(url) {
    try {
        const pathname = new URL(url).pathname;
        const segments = pathname.split('/').filter(Boolean);
        const lastSegment = segments[segments.length - 1] || '';
        const number = Number(lastSegment.match(/(\d+)(?:\D*)$/)?.[1]);
        return Number.isFinite(number) ? number : null;
    } catch { return null; }
}

function parseSearchResultsFromHtml(html, domain) {
    const $ = cheerio.load(html);
    const results = [];
    $('article.Anime, .ListAnimes li article').each((_, element) => {
        const card = $(element);
        const link = card.find("a[href^='/anime/']").first().attr('href') || card.find('a').first().attr('href');
        const title = card.find('h3.Title').first().text().trim() || null;
        const image = card.find('img').first().attr('src') || card.find('img').first().attr('data-src') || null;
        if (!link || !title) return;
        const slug = link.split('/').filter(Boolean).pop() || null;
        results.push({
            titulo: title,
            slug,
            urlAnime: resolveAbsoluteUrl(link, domain),
            imagen: resolveAbsoluteUrl(image, domain),
            tipo: card.find('.Type').first().text().trim() || null,
        });
    });
    return results;
}

function parseAnimeInfoFromHtml(html, domain) {
    const $ = cheerio.load(html);
    const title = $('h1').first().text().trim() || null;
    const description = $('.Description').first().text().trim() || null;
    const image = $('.AnimeCover img').attr('src') || $('.cover img').attr('src') || null;
    const genres = [];
    $('.Nvgnrs a').each((_, link) => {
        const name = $(link).text().trim();
        if (name) genres.push({ id: null, name, slug: name.toLowerCase().replace(/\s+/g, '-'), malId: null });
    });
    return { title, description, image, genres, type: $('.Type').first().text().trim() || null };
}

function parseEpisodeListFromScript(html, domain, slug) {
    const episodesLiteral = extractVarLiteral(html, 'episodes');
    if (!episodesLiteral) return [];
    const list = safeEvaluate(`(${episodesLiteral})`);
    if (!Array.isArray(list)) return [];
    return list.map((entry) => {
        if (!Array.isArray(entry) || entry.length === 0) return null;
        const number = parseNumber(entry[0]);
        if (!number && number !== 0) return null;
        const url = slug ? `https://${domain}/ver/${slug}-${number}` : null;
        return { id: entry[1] ?? null, number, title: `Episodio ${number}`, url };
    }).filter((ep) => ep && ep.url);
}

function parseVideoSources(html) {
    const videosLiteral = extractVarLiteral(html, 'videos');
    if (!videosLiteral) return null;
    let parsed = safeEvaluate(`(${videosLiteral})`);
    if (!parsed || typeof parsed !== 'object') return null;
    for (const [, entries] of Object.entries(parsed)) {
        if (!Array.isArray(entries)) continue;
        for (const entry of entries) {
            if (!entry || typeof entry !== 'object') continue;
            for (const urlField of ['code', 'url', 'embed', 'file']) {
                if (entry[urlField] && typeof entry[urlField] === 'string') {
                    const decoded = tryDecodeBase64(entry[urlField]);
                    entry[urlField] = decoded || decodeUrlEscapes(entry[urlField]);
                }
            }
        }
    }
    return parsed;
}

// ── API PÚBLICA ──────────────────────────────────────────

async function searchAnime(query, domainCandidate) {
    const cleanQuery = (query || '').toString().trim();
    if (!cleanQuery) throw new ApiError(400, 'Se requiere el parámetro q');
    const domain = (domainCandidate || DEFAULT_DOMAIN).toString().trim();
    const html = await fetchHtml(`https://${domain}/browse?q=${encodeURIComponent(cleanQuery)}`);
    const results = parseSearchResultsFromHtml(html, domain);
    return { success: true, data: { query: cleanQuery, results, count: results.length }, source: 'animeflv' };
}

async function getAnimeInfo(urlCandidate) {
    const normalizedUrl = resolveAbsoluteUrl(urlCandidate, DEFAULT_DOMAIN);
    if (!normalizedUrl) throw new ApiError(400, 'URL inválida');
    const parsed = new URL(normalizedUrl);
    const domain = parsed.hostname || DEFAULT_DOMAIN;
    const segments = parsed.pathname.split('/').filter(Boolean);
    let slug = segments[1] || '';
    if (segments[0] === 'ver') slug = (segments[1] || '').replace(/-\d+$/, '');
    if (segments[0] === 'anime') slug = segments[1] || '';
    if (!slug) throw new ApiError(400, 'URL inválida');

    const html = await fetchHtml(`https://${domain}/anime/${slug}`);
    const info = parseAnimeInfoFromHtml(html, domain);
    const episodes = parseEpisodeListFromScript(html, domain, slug);

    // Extraer ID numérico para miniaturas
    let animeId = null;
    const $ = cheerio.load(html);
    $('script').each((_, el) => {
        const code = $(el).html();
        if (code && code.includes('var anime_info')) {
            const match = code.match(/var anime_info\s*=\s*\["(\d+)"/);
            if (match) animeId = match[1];
        }
    });

    const episodiosConMiniatura = episodes.map(ep => ({
        ...ep,
        miniatura: animeId ? `https://cdn.animeflv.net/screenshots/${animeId}/${ep.number}/th_3.jpg` : null,
        urlVer: ep.url,
    }));

    return {
        success: true,
        data: {
            id: animeId ? Number(animeId) : null,
            titulo: info.title,
            sinopsis: info.description,
            imagenPortada: resolveAbsoluteUrl(info.image, domain),
            imagenFondo: resolveAbsoluteUrl(info.image, domain),
            tipo: info.type,
            estado: null,
            calificacion: 0.0,
            generos: info.genres,
            totalEpisodios: episodes.length,
            episodios: episodiosConMiniatura,
        },
        source: 'animeflv',
    };
}

async function getEpisodeLinks(urlCandidate, includeMegaRaw, excludeServersRaw) {
    const normalizedUrl = resolveAbsoluteUrl(urlCandidate, DEFAULT_DOMAIN);
    if (!normalizedUrl) throw new ApiError(400, 'URL inválida');
    const epDomain = new URL(normalizedUrl).hostname || DEFAULT_DOMAIN;
    const includeMega = String(includeMegaRaw).toLowerCase() === 'true';
    const excludedTokens = buildExcludedTokens(includeMega, excludeServersRaw);

    const html = await fetchHtml(normalizedUrl);
    const streamLinks = { SUB: [], DUB: [] };
    const downloadLinks = { SUB: [], DUB: [] };

    const videoSources = parseVideoSources(html);
    if (videoSources) {
        for (const [key, entries] of Object.entries(videoSources)) {
            const variant = normalizeVariantKey(key);
            if (!Array.isArray(entries)) continue;
            for (const entry of entries) {
                if (!entry) continue;
                const url = entry.code || entry.url || entry.embed || entry.file || null;
                const link = buildLinkRecord(entry.title || entry.server || 'Unknown', url, null);
                if (link) pushDeduped(streamLinks[variant], link);
            }
        }
    }

    const filteredSub = filterLinksByServers(streamLinks.SUB, excludedTokens);
    const filteredDub = filterLinksByServers(streamLinks.DUB, excludedTokens);
    const episodeNumber = parseEpisodeNumberFromUrl(normalizedUrl);

    return {
        success: true,
        data: {
            episode: episodeNumber,
            servers: {
                sub: sanitizeLinksForResponse(filteredSub),
                dub: sanitizeLinksForResponse(filteredDub),
            },
            streamLinks: { SUB: sanitizeLinksForResponse(filteredSub), DUB: sanitizeLinksForResponse(filteredDub) },
            downloadLinks: { SUB: sanitizeLinksForResponse(filterLinksByServers(downloadLinks.SUB, excludedTokens)), DUB: [] },
        },
        source: 'animeflv',
    };
}

async function getCatalog(page, genre) {
    const pageNum = Math.max(1, parseInt(page) || 1);
    let url = `https://${DEFAULT_DOMAIN}/browse?page=${pageNum}`;
    if (genre) url += `&genre[]=${encodeURIComponent(genre.trim().toLowerCase())}`;
    const html = await fetchHtml(url);
    const results = parseSearchResultsFromHtml(html, DEFAULT_DOMAIN);
    return { success: true, data: { page: pageNum, genre: genre || null, results, count: results.length, hasMore: results.length >= 20 }, source: 'animeflv' };
}

async function getHome() {
    const html = await fetchHtml(`https://${DEFAULT_DOMAIN}`);
    const $ = cheerio.load(html);

    // Últimos episodios
    const ultimosEpisodios = [];
    $('.ListEpisodios li').each((_, el) => {
        const titulo = $(el).find('.Title').text().trim();
        const episodioText = $(el).find('.Capi').text().trim();
        const ruta = $(el).find('a').attr('href');
        const urlEpisodio = ruta ? `https://${DEFAULT_DOMAIN}${ruta}` : null;
        const imagenRuta = $(el).find('.Image img').attr('src') || $(el).find('.Image img').attr('data-cfsrc');
        const imagen = imagenRuta ? (imagenRuta.startsWith('http') ? imagenRuta : `https://${DEFAULT_DOMAIN}${imagenRuta}`) : null;
        if (titulo) ultimosEpisodios.push({ titulo, episodio: parseInt(episodioText.replace('Episodio ', '')) || episodioText, imagen, urlEpisodio });
    });

    // Populares (articles)
    const populares = [];
    $('article').each((_, el) => {
        const ruta = $(el).find('a').first().attr('href');
        const urlAnime = ruta ? `https://${DEFAULT_DOMAIN}${ruta}` : null;
        const titulo = $(el).find('h3.Title').text().trim();
        const imagenRuta = $(el).find('.Image img').attr('src');
        const imagen = imagenRuta ? (imagenRuta.startsWith('http') ? imagenRuta : `https://${DEFAULT_DOMAIN}${imagenRuta}`) : null;
        const tipo = $(el).find('.Type').first().text().trim();
        const rating = $(el).find('.Vts').text().trim();
        const sinopsis = $(el).find('.Description p').last().text().trim();
        if (titulo && urlAnime) populares.push({ titulo, imagen, urlAnime, tipo, rating, sinopsis });
    });

    return {
        success: true,
        data: {
            top5: populares.slice(0, 5),
            populares: populares.slice(5, 20),
            ultimosEpisodios: ultimosEpisodios.slice(0, 15),
        },
        source: 'animeflv',
    };
}

async function getNovedades() {
    const html = await fetchHtml(`https://${DEFAULT_DOMAIN}/browse?order=added`);
    const $ = cheerio.load(html);
    const animes = [];
    $('.ListAnimes li article').each((_, el) => {
        const titulo = $(el).find('.Title').text().trim();
        const ruta = $(el).find('a').attr('href');
        const urlAnime = ruta ? `https://${DEFAULT_DOMAIN}${ruta}` : null;
        const imagenRuta = $(el).find('img').attr('src') || $(el).find('img').attr('data-cfsrc');
        const imagen = imagenRuta ? (imagenRuta.startsWith('http') ? imagenRuta : `https://${DEFAULT_DOMAIN}${imagenRuta}`) : null;
        if (titulo && urlAnime) animes.push({ titulo, imagen, urlAnime, tipo: $(el).find('.Type').text().trim() });
    });
    return { success: true, total: animes.length, data: animes.slice(0, 15) };
}

module.exports = { searchAnime, getAnimeInfo, getEpisodeLinks, getCatalog, getHome, getNovedades };
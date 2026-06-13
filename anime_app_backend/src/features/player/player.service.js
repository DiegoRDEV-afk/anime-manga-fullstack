const axios = require('axios');
const cheerio = require('cheerio');
const { getBrowser } = require('../../shared/utils/browser');

const HTTP_HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
    'Accept': '*/*',
    'Accept-Language': 'es-ES,es;q=0.9,en;q=0.8',
};

// ─────────────────────────────────────────
// EXTRACTOR: YOURUPLOAD
// ─────────────────────────────────────────
async function extraerYourUpload(url) {
    try {
        const { data } = await axios.get(url, { headers: HTTP_HEADERS });
        const match = data.match(/file:\s*["']([^"']+\.mp4[^"']*)['"]/);
        if (!match) return null;
        const videoUrl = match[1];
        if (!videoUrl.startsWith('http') || videoUrl.includes('novideo')) return null;
        return { url: videoUrl, referer: 'https://www.yourupload.com/', provider: 'YourUpload' };
    } catch {
        return null;
    }
}

// ─────────────────────────────────────────
// EXTRACTOR: OKRU
// ─────────────────────────────────────────
async function extraerOkru(url) {
    try {
        const { data } = await axios.get(url, { headers: HTTP_HEADERS });
        const match = data.match(/"url":"([^"]+\.mp4[^"]*)"/);
        if (!match) return null;
        return { url: match[1].replace(/\\/g, ''), referer: 'https://ok.ru/', provider: 'Okru' };
    } catch {
        return null;
    }
}

// ─────────────────────────────────────────
// EXTRACTOR: MP4UPLOAD (via JKAnime)
// ─────────────────────────────────────────
async function extraerMp4Upload(url) {
    try {
        const { data } = await axios.get(url, {
            headers: { ...HTTP_HEADERS, 'Referer': 'https://jkanime.net/' }
        });
        const match = data.match(/src:\s*["']([^"']+\.mp4[^"']*)['"]/);
        if (!match) return null;
        return { url: match[1], referer: 'https://www.mp4upload.com/', provider: 'Mp4upload' };
    } catch {
        return null;
    }
}

// ─────────────────────────────────────────
// EXTRACTOR: MEDIAFIRE (via JKAnime)
// ─────────────────────────────────────────
async function extraerMediafire(url) {
    try {
        const { data } = await axios.get(url, { headers: HTTP_HEADERS });
        const $ = cheerio.load(data);
        const downloadUrl = $('a#downloadButton').attr('href') ||
            $('a[aria-label="Download file"]').attr('href');
        if (!downloadUrl) return null;
        return { url: downloadUrl, referer: 'https://www.mediafire.com/', provider: 'Mediafire' };
    } catch {
        return null;
    }
}

// ─────────────────────────────────────────
// EXTRACTOR: STREAMWISH via Puppeteer
// ─────────────────────────────────────────
async function extraerStreamWish(url) {
    let page = null;
    try {
        const browser = await getBrowser();
        page = await browser.newPage();
        let m3u8 = null;

        page.on('request', req => {
            const reqUrl = req.url();
            if (reqUrl.includes('master.m3u8')) m3u8 = reqUrl;
        });

        await page.goto(url, { waitUntil: 'networkidle2', timeout: 30000 });
        await new Promise(r => setTimeout(r, 5000));

        if (!m3u8) return null;
        return { url: m3u8, referer: 'https://streamwish.to/', provider: 'StreamWish', type: 'm3u8' };
    } catch {
        return null;
    } finally {
        if (page) await page.close();
    }
}

// ─────────────────────────────────────────
// FALLBACK: JKANIME
// ─────────────────────────────────────────
async function extraerDesdeJKAnime(animeflvUrl) {
    try {
        // Extraer slug y episodio de la URL de AnimeFLV
        const slug = animeflvUrl.split('/ver/')[1]?.replace(/-(\d+)$/, '');
        const episodio = animeflvUrl.match(/-(\d+)$/)?.[1];
        if (!slug || !episodio) return null;

        const jkUrl = `https://jkanime.net/${slug}/${episodio}/`;
        const { data } = await axios.get(jkUrl, { headers: HTTP_HEADERS });

        // Extraer servers de JKAnime
        const serversMatch = data.match(/var servers\s*=\s*(\[[\s\S]*?\]);/);
        if (!serversMatch) return null;

        const servers = JSON.parse(serversMatch[1]);
        const decodedServers = servers.map(s => ({
            ...s,
            url: Buffer.from(s.remote, 'base64').toString('utf8').trim()
        }));

        console.log(`🎌 JKAnime servidores: ${decodedServers.map(s => s.server).join(', ')}`);

        // Intentar Mediafire primero (más rápido)
        const mediafire = decodedServers.find(s => s.server === 'Mediafire');
        if (mediafire?.url) {
            const resultado = await extraerMediafire(mediafire.url);
            if (resultado) return resultado;
        }

        // Intentar Mp4upload
        const mp4upload = decodedServers.find(s => s.server === 'Mp4upload');
        if (mp4upload?.url) {
            const resultado = await extraerMp4Upload(mp4upload.url);
            if (resultado) return resultado;
        }

        return null;
    } catch (e) {
        console.log('JKAnime fallback error:', e.message);
        return null;
    }
}

// ─────────────────────────────────────────
// RESOLVER PRINCIPAL
// ─────────────────────────────────────────
async function resolverVideo(episodeUrl) {
    try {
        // Obtener servidores del episodio de AnimeFLV
        const { data } = await axios.get(episodeUrl, { headers: HTTP_HEADERS });
        const $ = cheerio.load(data);
        let servidores = null;

        $('script').each((_, el) => {
            const code = $(el).html();
            if (code && code.includes('var videos =')) {
                code.split('\n').forEach(linea => {
                    const l = linea.trim();
                    if (l.includes('var videos =') && !l.startsWith('//')) {
                        try {
                            const json = JSON.parse(l.replace('var videos = ', '').replace(/;$/, ''));
                            servidores = json.SUB || json.sub || [];
                        } catch { }
                    }
                });
            }
        });

        if (!servidores || servidores.length === 0) {
            console.log('⚠️ No se encontraron servidores en AnimeFLV, usando JKAnime...');
            return await extraerDesdeJKAnime(episodeUrl);
        }

        console.log(`\n🖥️ Servidores: ${servidores.map(s => s.title).join(', ')}`);

        // INTENTO 1: YourUpload
        const yu = servidores.find(s => s.server === 'yu');
        if (yu?.code) {
            console.log('🔍 Intentando YourUpload...');
            const resultado = await extraerYourUpload(yu.code);
            if (resultado) { console.log('🟢 Éxito con YourUpload.'); return resultado; }
            console.log('⚠️ YourUpload falló.');
        }

        // INTENTO 2: Okru
        const okru = servidores.find(s => s.server === 'okru');
        if (okru?.code) {
            console.log('🔍 Intentando Okru...');
            const resultado = await extraerOkru(okru.code);
            if (resultado) { console.log('🟢 Éxito con Okru.'); return resultado; }
            console.log('⚠️ Okru falló.');
        }

        // INTENTO 3: Fallback a JKAnime
        console.log('🔀 Fallback a JKAnime...');
        const jkResultado = await extraerDesdeJKAnime(episodeUrl);
        if (jkResultado) { console.log('🟢 Éxito con JKAnime.'); return jkResultado; }

        return null;
    } catch (error) {
        console.error('❌ Error en resolverVideo:', error.message);
        return null;
    }
}

module.exports = { resolverVideo };
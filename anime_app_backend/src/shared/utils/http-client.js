const axios = require('axios');

const DEFAULT_HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'es-ES,es;q=0.9,en;q=0.8',
};

async function fetchHtml(url, extraHeaders = {}) {
    const timeout = Number(process.env.REQUEST_TIMEOUT_MS || 15000);
    const response = await axios.get(url, {
        timeout,
        headers: { ...DEFAULT_HEADERS, ...extraHeaders },
        maxRedirects: 5,
        validateStatus: (status) => status >= 200 && status < 400,
    });
    return response.data;
}

async function fetchStream(url, extraHeaders = {}) {
    const response = await axios({
        method: 'get',
        url,
        headers: { ...DEFAULT_HEADERS, ...extraHeaders },
        responseType: 'stream',
    });
    return response;
}

module.exports = { fetchHtml, fetchStream, DEFAULT_HEADERS };
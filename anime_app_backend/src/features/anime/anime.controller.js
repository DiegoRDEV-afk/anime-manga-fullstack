const animeService = require('./anime.service');

// 🛡️ EL ESCUDO DEFINITIVO: AdBlock + PopUp Blocker + Anti-Redirección
const antiAdsScript = `
    (function() {
        console.log("🚀 Desplegando Escudo Defensivo Ultra-Agresivo...");

        // ── 1. BLOQUEO ABSOLUTO DE POPUPS Y VENTANAS ───────────────────────
        window.open = function() { return null; };
        window.alert = function() { return true; };
        window.confirm = function() { return true; };
        window.prompt = function() { return null; };
        window.onbeforeunload = null;

        if (Object.defineProperty) {
            try {
                Object.defineProperty(window, 'open', { value: function() { return null; }, writable: false, configurable: false });
            } catch(e) { console.log("⚠️ No se pudo congelar window.open, pero sigue bloqueado."); }
        }

        // ── 2. DETECTOR Y DESTRUCTOR DE IFRAMES OCULTOS (CADA 100MS) ──────
        setInterval(() => {
            const iframes = document.getElementsByTagName('iframe');
            for (let i = iframes.length - 1; i >= 0; i--) {
                const src = iframes[i].src || '';
                if (src && !src.includes(window.location.host) && 
                    !src.includes('streamwish') && !src.includes('streamtape') && 
                    !src.includes('player') && !src.includes('embed')) {
                    console.log("💀 Iframe publicitario fantasma destruido:", src);
                    iframes[i].remove();
                }
            }

            const divs = document.getElementsByTagName('div');
            for (let i = divs.length - 1; i >= 0; i--) {
                const style = window.getComputedStyle(divs[i]);
                if (style.position === 'absolute' || style.position === 'fixed') {
                    if (parseInt(style.zIndex) > 999 && !divs[i].innerHTML.includes('video')) {
                        console.log("💀 Capa invisible anti-click eliminada.");
                        divs[i].remove();
                    }
                }
            }
        }, 100);

        // ── 3. INTERCEPTOR DE CLICKS FANTASMAS (AdBlock a nivel Evento) ────
        const prevenirPublicidadPorClick = function(e) {
            const target = e.target;
            if (target.tagName === 'A' && target.target === '_blank') {
                e.preventDefault();
                e.stopPropagation();
                console.log("🚫 Enlace externo target='_blank' interceptado y bloqueado.");
                return false;
            }
        };

        document.addEventListener('click', prevenirPublicidadPorClick, true);
        document.addEventListener('mousedown', prevenirPublicidadPorClick, true);
        document.addEventListener('pointerdown', prevenirPublicidadPorClick, true);

        // ── 4. CAPADO DE REDIRECCIONES EN LA PESTAÑA PRINCIPAL ──────────────
        let urlOriginal = window.location.href;
        window.addEventListener('unload', function(e) {
            if (window.location.href !== urlOriginal && !window.location.href.includes('streamwish') && !window.location.href.includes('streamtape')) {
                window.location.href = urlOriginal;
            }
        });

        console.log("🔥 ¡Sistema Blindado de extremo a extremo exitosamente!");
    })();
`;

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
        
        if (result && result.success) {
            result.scriptBlinder = antiAdsScript;
        }
        
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
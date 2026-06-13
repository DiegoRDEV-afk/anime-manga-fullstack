const { resolverVideo } = require('./player.service');

async function getVideoUrl(req, res, next) {
    try {
        const { url } = req.query;
        if (!url) return res.status(400).json({ success: false, message: 'Parámetro url requerido' });

        console.log(`\n🎬 Resolviendo: ${url}`);
        const resultado = await resolverVideo(url);

        if (!resultado) {
            return res.status(404).json({ success: false, message: 'No se encontró enlace reproducible.' });
        }

        return res.json({ success: true, ...resultado });
    } catch (error) {
        next(error);
    }
}

module.exports = { getVideoUrl };
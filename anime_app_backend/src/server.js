const app = require('./app');
const { closeBrowser } = require('./shared/utils/browser');

const PORT = process.env.PORT || 3000;

const server = app.listen(PORT, () => {
    console.log('=================================================');
    console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
    console.log('=================================================');
    console.log(`📺 Anime:  http://localhost:${PORT}/api/anime`);
    console.log(`🎬 Player: http://localhost:${PORT}/api/player`);
});

// Cerrar browser de puppeteer al apagar el servidor
process.on('SIGINT', async () => {
    console.log('\n🛑 Apagando servidor...');
    await closeBrowser();
    server.close(() => process.exit(0));
});

process.on('SIGTERM', async () => {
    await closeBrowser();
    server.close(() => process.exit(0));
});
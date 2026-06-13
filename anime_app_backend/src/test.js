const puppeteer = require('puppeteer');

(async () => {
    const browser = await puppeteer.launch({ 
        headless: true,
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    const page = await browser.newPage();
    let m3u8 = null;

    page.on('request', req => {
        const url = req.url();
        if (url.includes('.m3u8')) {
            console.log('M3U8:', url);
            m3u8 = url;
        }
    });

    await page.goto('https://voe.sx/e/mhvwyqjsw2gk', { 
        waitUntil: 'networkidle2', 
        timeout: 30000 
    });
    
    await new Promise(r => setTimeout(r, 8000));
    console.log('Resultado:', m3u8 || 'No encontrado');
    await browser.close();
})();
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 60 * 1000, // 1 minuto
    max: 100,
    message: { success: false, message: 'Demasiadas peticiones, intenta más tarde.' },
});

module.exports = { limiter };
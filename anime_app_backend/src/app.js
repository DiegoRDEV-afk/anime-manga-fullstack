const express = require('express');
const { errorMiddleware } = require('./shared/middleware/error.middleware');
const { limiter } = require('./shared/middleware/rate-limit');

const animeRoutes = require('./features/anime/anime.routes');
const playerRoutes = require('./features/player/player.routes');

const app = express();

app.use(express.json());
app.use(limiter);

// Rutas
app.use('/api/anime', animeRoutes);
app.use('/api/player', playerRoutes);

// Manejo de errores
app.use(errorMiddleware);

module.exports = app;
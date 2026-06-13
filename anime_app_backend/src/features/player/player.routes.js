const express = require('express');
const router = express.Router();
const controller = require('./player.controller');

// GET /api/player/video?url=https://animeflv.net/ver/one-piece-tv-1
router.get('/video', controller.getVideoUrl);

module.exports = router;
const express = require('express');
const router = express.Router();

// Rutas temporales - las llenamos después
router.get('/', (req, res) => {
    res.json({ success: true, message: 'Anime API funcionando' });
});

module.exports = router;
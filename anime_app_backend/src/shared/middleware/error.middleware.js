const { ApiError } = require('../utils/api-error');

function errorMiddleware(err, req, res, next) {
    if (err instanceof ApiError) {
    return res.status(err.statusCode).json({
        success: false,
        message: err.message,
        details: err.details || null,
    });
    }

    console.error('Error no controlado:', err);
    return res.status(500).json({
        success: false,
        message: 'Error interno del servidor',
    });
}

module.exports = { errorMiddleware };
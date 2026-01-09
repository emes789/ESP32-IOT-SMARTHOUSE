/**
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * 🔐 MIDDLEWARE AUTORYZACJI
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 */

/**
 * Weryfikacja klucza API dla urządzeń ESP32
 * Klucz przesyłany w nagłówku X-API-Key
 */
function authenticateESP32(req, res, next) {
  const apiKey = req.headers['x-api-key'];
  const expectedKey = process.env.ESP32_API_KEY;

  if (!expectedKey) {
    console.warn('⚠️  ESP32_API_KEY not configured in environment');
    return next(); // Tryb development - przepuść bez autoryzacji
  }

  if (!apiKey) {
    return res.status(401).json({
      success: false,
      error: 'Missing API key',
      message: 'X-API-Key header is required'
    });
  }

  if (apiKey !== expectedKey) {
    console.warn(`🚫 Invalid ESP32 API key attempt from ${req.ip}`);
    return res.status(403).json({
      success: false,
      error: 'Invalid API key'
    });
  }

  next();
}

/**
 * Weryfikacja klucza API dla aplikacji Flutter
 * Klucz przesyłany w nagłówku Authorization: Bearer <key>
 */
function authenticateFlutter(req, res, next) {
  const authHeader = req.headers['authorization'];
  const expectedKey = process.env.FLUTTER_API_KEY;

  if (!expectedKey) {
    console.warn('⚠️  FLUTTER_API_KEY not configured in environment');
    return next(); // Tryb development - przepuść bez autoryzacji
  }

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      success: false,
      error: 'Missing authorization',
      message: 'Authorization header with Bearer token is required'
    });
  }

  const token = authHeader.substring(7);

  if (token !== expectedKey) {
    console.warn(`🚫 Invalid Flutter API key attempt from ${req.ip}`);
    return res.status(403).json({
      success: false,
      error: 'Invalid authorization token'
    });
  }

  next();
}

/**
 * Opcjonalna autoryzacja - loguje ale przepuszcza
 * Przydatne dla endpointów które mają działać publicznie w dev
 */
function optionalAuth(req, res, next) {
  const apiKey = req.headers['x-api-key'];
  const authHeader = req.headers['authorization'];

  if (apiKey || authHeader) {
    req.isAuthenticated = true;
    req.authType = apiKey ? 'esp32' : 'flutter';
  } else {
    req.isAuthenticated = false;
  }

  next();
}

module.exports = {
  authenticateESP32,
  authenticateFlutter,
  optionalAuth
};

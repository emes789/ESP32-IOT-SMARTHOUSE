/**
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * ❌ MIDDLEWARE OBSŁUGI BŁĘDÓW
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 */

/**
 * Globalny handler błędów
 */
function errorHandler(err, req, res, next) {
  console.error('❌ Error:', err);

  // Błędy walidacji MongoDB
  if (err.name === 'ValidationError') {
    return res.status(400).json({
      success: false,
      error: 'Validation Error',
      details: err.message
    });
  }

  // Błędy duplikacji MongoDB
  if (err.code === 11000) {
    return res.status(409).json({
      success: false,
      error: 'Duplicate Entry',
      details: 'A record with this identifier already exists'
    });
  }

  // Błędy JSON parse
  if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
    return res.status(400).json({
      success: false,
      error: 'Invalid JSON',
      details: 'Request body must be valid JSON'
    });
  }

  // Domyślny błąd serwera
  const statusCode = err.statusCode || 500;
  const message = process.env.NODE_ENV === 'production' 
    ? 'Internal server error' 
    : err.message;

  res.status(statusCode).json({
    success: false,
    error: message,
    ...(process.env.NODE_ENV !== 'production' && { stack: err.stack })
  });
}

/**
 * Async wrapper - łapie błędy z async funkcji
 */
function asyncHandler(fn) {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}

module.exports = {
  errorHandler,
  asyncHandler
};

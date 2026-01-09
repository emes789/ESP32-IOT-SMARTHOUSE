# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🐳 DOCKERFILE - Smart Home IoT API
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

FROM node:20-alpine

# Metadata
LABEL maintainer="Smart Home IoT Team"
LABEL description="REST API for Smart Home IoT System"

# Ustaw zmienną środowiskową
ENV NODE_ENV=production

# Utwórz katalog aplikacji
WORKDIR /app

# Skopiuj pliki package
COPY package*.json ./

# Zainstaluj zależności (tylko produkcyjne)
RUN npm install --omit=dev && npm cache clean --force

# Skopiuj kod źródłowy
COPY src/ ./src/

# Utwórz użytkownika non-root dla bezpieczeństwa
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs

# Zmień właściciela plików
RUN chown -R nodejs:nodejs /app

# Przełącz na użytkownika non-root
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/api/health/live || exit 1

# Start aplikacji
CMD ["node", "src/server.js"]

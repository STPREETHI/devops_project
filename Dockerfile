# ─── Stage 1: Build ───────────────────────────────
FROM node:18-alpine AS builder
WORKDIR /app
# Copy dependency files first (layer cache optimization)
COPY package*.json ./
RUN npm ci --only=production 2>/dev/null || echo "No npm packages"

# ─── Stage 2: Production ──────────────────────────
FROM nginx:alpine
# Copy built assets from builder
COPY --from=builder /app/node_modules /usr/share/nginx/html/node_modules
COPY app/ /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

# Stage 1: Build (using nginx alpine - optimized & small)
FROM nginx:alpine AS builder
# Copy static files
COPY app/ /usr/share/nginx/html/

# Stage 2: Production
FROM nginx:alpine
# Copy from builder (layer cache optimization)
COPY --from=builder /usr/share/nginx/html/ /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

# Lightweight nginx base image
FROM nginx:alpine

# Remove default nginx static content
RUN rm -rf /usr/share/nginx/html/*

# Copy your application files
COPY ./app /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx in foreground (required for containers)
CMD ["nginx", "-g", "daemon off;"]

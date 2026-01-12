# Multi-stage build for Astra Linux Threat Geo Mapper
FROM nginx:alpine AS production

# Metadata
LABEL maintainer="Astra Geo Mapper Team"
LABEL description="Astra Linux Threat Geo Mapper - Secure web application"
LABEL version="1.0.0"

# Security: Run as non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Copy application files
COPY astra_geo_mapper_secure.html /usr/share/nginx/html/index.html
COPY astra_geo_mapper.css /usr/share/nginx/html/
COPY screenshots/ /usr/share/nginx/html/screenshots/

# Create nginx configuration with security headers
# Note: Using port 8080 for non-root user (ports < 1024 require root)
RUN echo 'server {' > /etc/nginx/conf.d/default.conf && \
    echo '    listen 8080;' >> /etc/nginx/conf.d/default.conf && \
    echo '    server_name _;' >> /etc/nginx/conf.d/default.conf && \
    echo '    root /usr/share/nginx/html;' >> /etc/nginx/conf.d/default.conf && \
    echo '    index index.html;' >> /etc/nginx/conf.d/default.conf && \
    echo '' >> /etc/nginx/conf.d/default.conf && \
    echo '    # Security Headers' >> /etc/nginx/conf.d/default.conf && \
    echo '    add_header Content-Security-Policy "default-src '\''self'\''; script-src '\''self'\'' '\''unsafe-inline'\'' https://cdnjs.cloudflare.com; style-src '\''self'\'' '\''unsafe-inline'\'' https://cdnjs.cloudflare.com; img-src '\''self'\'' data: https: blob:; connect-src '\''self'\'' https://*.basemaps.cartocdn.com https://*.cartocdn.com; font-src '\''self'\'' data: https:; frame-ancestors '\''none'\'';" always;' >> /etc/nginx/conf.d/default.conf && \
    echo '    add_header X-Content-Type-Options "nosniff" always;' >> /etc/nginx/conf.d/default.conf && \
    echo '    add_header X-Frame-Options "DENY" always;' >> /etc/nginx/conf.d/default.conf && \
    echo '    add_header X-XSS-Protection "1; mode=block" always;' >> /etc/nginx/conf.d/default.conf && \
    echo '    add_header Referrer-Policy "strict-origin-when-cross-origin" always;' >> /etc/nginx/conf.d/default.conf && \
    echo '    add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;' >> /etc/nginx/conf.d/default.conf && \
    echo '' >> /etc/nginx/conf.d/default.conf && \
    echo '    # Hide nginx version' >> /etc/nginx/conf.d/default.conf && \
    echo '    server_tokens off;' >> /etc/nginx/conf.d/default.conf && \
    echo '' >> /etc/nginx/conf.d/default.conf && \
    echo '    location / {' >> /etc/nginx/conf.d/default.conf && \
    echo '        try_files $uri $uri/ /index.html;' >> /etc/nginx/conf.d/default.conf && \
    echo '    }' >> /etc/nginx/conf.d/default.conf && \
    echo '' >> /etc/nginx/conf.d/default.conf && \
    echo '    # Cache static assets' >> /etc/nginx/conf.d/default.conf && \
    echo '    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg|woff|woff2|ttf|eot)$ {' >> /etc/nginx/conf.d/default.conf && \
    echo '        expires 1y;' >> /etc/nginx/conf.d/default.conf && \
    echo '        add_header Cache-Control "public, immutable";' >> /etc/nginx/conf.d/default.conf && \
    echo '    }' >> /etc/nginx/conf.d/default.conf && \
    echo '}' >> /etc/nginx/conf.d/default.conf

# Change ownership to non-root user and create necessary directories
RUN chown -R appuser:appgroup /usr/share/nginx/html && \
    chown -R appuser:appgroup /var/cache/nginx && \
    chown -R appuser:appgroup /var/log/nginx && \
    chown -R appuser:appgroup /etc/nginx/conf.d && \
    mkdir -p /run/nginx && \
    chown -R appuser:appgroup /run/nginx && \
    chown -R appuser:appgroup /var/run/nginx

# Update nginx config to work with non-root user
# Change PID file location and comment out user directive
RUN sed -i.bak 's|pid /var/run/nginx.pid;|pid /run/nginx/nginx.pid;|g' /etc/nginx/nginx.conf && \
    sed -i.bak 's|^user  nginx;|# user  nginx; # Running as non-root|g' /etc/nginx/nginx.conf && \
    grep -q "pid /run/nginx/nginx.pid" /etc/nginx/nginx.conf || \
    (echo "pid /run/nginx/nginx.pid;" >> /etc/nginx/nginx.conf && \
     sed -i.bak '/^pid/d' /etc/nginx/nginx.conf && \
     sed -i.bak '1a pid /run/nginx/nginx.pid;' /etc/nginx/nginx.conf)

# Switch to non-root user
USER appuser

# Expose port (8080 for non-root user)
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

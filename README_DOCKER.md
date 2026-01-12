# 🐳 Docker Deployment Guide

This document explains how to build and run the Astra Linux Threat Geo Mapper using Docker.

## Quick Start

### Using Docker Compose (Recommended)

```bash
# Start the application
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the application
docker-compose down
```

The application will be available at: http://localhost:8080

### Using Docker Directly

```bash
# Build the image
docker build -t astra-geo-mapper:latest .

# Run the container
docker run -d --name astra-geo-mapper -p 8080:80 astra-geo-mapper:latest

# View logs
docker logs -f astra-geo-mapper

# Stop the container
docker stop astra-geo-mapper
docker rm astra-geo-mapper
```

### Using Makefile

```bash
# Install dependencies and pre-commit hooks
make install

# Build Docker image
make build

# Run container
make run

# Stop container
make docker-stop

# Clean up
make clean
```

## Security Features

The Docker image includes:

- ✅ **Non-root user**: Runs as user `appuser` (UID 1001)
- ✅ **Security headers**: All security headers configured in nginx
- ✅ **Read-only filesystem**: Container runs with read-only root filesystem
- ✅ **Health checks**: Built-in health check endpoint
- ✅ **Minimal base image**: Uses Alpine Linux for smaller attack surface

## Security Headers

The nginx configuration automatically adds:

- `Content-Security-Policy`
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `X-XSS-Protection: 1; mode=block`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Permissions-Policy`

## Production Deployment

### Environment Variables

Currently, no environment variables are required. The application is fully static.

### Port Configuration

Default port: `80` (inside container)

To change the external port:
```bash
docker run -d -p 3000:80 astra-geo-mapper:latest
```

### Volume Mounts

The application is self-contained. No volume mounts are required.

### Health Checks

The container includes a health check that runs every 30 seconds:

```bash
# Check container health
docker ps
# Look for "healthy" status
```

### Resource Limits

For production, consider adding resource limits:

```yaml
# docker-compose.yml
services:
  astra-geo-mapper:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 128M
        reservations:
          cpus: '0.25'
          memory: 64M
```

## Troubleshooting

### Container won't start

```bash
# Check logs
docker logs astra-geo-mapper

# Check if port is in use
netstat -tuln | grep 8080
```

### Permission issues

The container runs as non-root. If you encounter permission issues:

```bash
# Check container user
docker exec astra-geo-mapper id
# Should show: uid=1001(appuser) gid=1001(appgroup)
```

### Health check failing

```bash
# Test health check manually
docker exec astra-geo-mapper wget --spider http://localhost/
```

## Building for Different Platforms

### AMD64 (Intel/AMD)

```bash
docker build --platform linux/amd64 -t astra-geo-mapper:amd64 .
```

### ARM64 (Apple Silicon, ARM servers)

```bash
docker build --platform linux/arm64 -t astra-geo-mapper:arm64 .
```

### Multi-platform build

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t astra-geo-mapper:latest .
```

## CI/CD Integration

The GitHub Actions workflow automatically builds and tests the Docker image on:

- Push to `main` branch
- Pull requests to `main`
- Tagged releases (v*.*.*)

See `.github/workflows/ci.yml` and `.github/workflows/docker-publish.yml` for details.

## Image Size

The final image is approximately **15-20 MB** (Alpine-based).

## Updating the Application

To update the application:

1. Make changes to source files
2. Rebuild the image: `docker build -t astra-geo-mapper:latest .`
3. Restart the container: `docker-compose restart` or `make docker-stop && make run`

## Security Considerations

- ✅ Runs as non-root user
- ✅ Read-only filesystem
- ✅ Security headers configured
- ✅ Minimal base image
- ✅ No unnecessary packages
- ✅ Regular security updates recommended

## Support

For issues or questions, please open an issue on GitHub.

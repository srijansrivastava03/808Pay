# 808Pay - Docker Quick Start Guide

## Prerequisites
- Docker Desktop (Mac/Windows) or Docker Engine (Linux)
- Docker Compose (included with Docker Desktop)
- `.env` file configured (see below)

## Quick Start (3 commands)

```bash
# 1. Build all containers
docker-compose build

# 2. Start all services
docker-compose up -d

# 3. Check status
docker-compose ps
```

**That's it!** Services will be available at:
- Backend: http://localhost:3000
- Reverse Proxy: http://localhost
- AlgoKit: http://localhost:4001

## Environment Setup

Create `.env` file in root directory:
```env
# Algorand
ALGORAND_SERVER=http://algokit:4001
ALGORAND_TOKEN=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
ALGORAND_NETWORK=localnet

# Smart Contract
CONTRACT_APP_ID=your-app-id
PAYMENT_PROCESSOR_ADDRESS=your-wallet-address

# Backend
PORT=3000
NODE_ENV=development
```

## Common Docker Commands

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f algokit
```

### Interact with Services
```bash
# Execute command in backend
docker-compose exec backend npm run build

# Get bash shell in backend
docker-compose exec backend bash

# Get bash shell in algokit
docker-compose exec algokit bash
```

### Development Workflow
```bash
# Start services (keep running)
docker-compose up

# In another terminal, make code changes
# Code will auto-reload via volume mounts

# Rebuild specific service
docker-compose up --build backend

# Restart specific service
docker-compose restart backend
```

### Cleanup
```bash
# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Remove all images
docker rmi 808pay-backend 808pay-algokit
```

## Health Checks

Each service has automatic health checks:

```bash
# Check if backend is healthy
docker-compose exec backend curl http://localhost:3000/health

# Check if algokit is healthy
docker-compose exec algokit curl http://localhost:4001/health

# View health status
docker-compose ps
```

## Testing Endpoints

```bash
# Health check
curl http://localhost/health

# List transactions
curl http://localhost/api/transactions

# Test endpoint
curl -X POST http://localhost/api/transactions/test
```

## Production Deployment

### Build for Registry
```bash
# Tag images
docker tag 808pay-backend your-registry/808pay-backend:1.0.0
docker tag 808pay-algokit your-registry/808pay-algokit:1.0.0

# Push to registry
docker push your-registry/808pay-backend:1.0.0
docker push your-registry/808pay-algokit:1.0.0
```

### SSL/TLS in Production
```bash
# Uncomment HTTPS section in nginx.conf
# Place certificates in ./ssl/
# cert.pem - SSL certificate
# key.pem - Private key

# Rebuild
docker-compose build nginx
docker-compose up -d nginx
```

### Environment Variables in Production
Use `.env.production`:
```env
NODE_ENV=production
ALGORAND_SERVER=https://testnet-algorand.api.purestake.io/ps2
ALGORAND_TOKEN=your-real-token
```

## Troubleshooting

### Port Already in Use
```bash
# Find process using port 3000
lsof -i :3000

# Kill process
kill -9 <PID>

# Or change port in docker-compose.yml
# "3001:3000" instead of "3000:3000"
```

### Container Won't Start
```bash
# View logs
docker-compose logs backend

# Rebuild from scratch
docker-compose down -v
docker-compose build --no-cache
docker-compose up
```

### Volume Mount Issues
```bash
# Verify volumes
docker volume ls

# Remove all unused volumes
docker volume prune

# Remount volumes
docker-compose down
docker-compose up -d
```

### Network Issues
```bash
# View network
docker network ls

# Inspect network
docker network inspect 808pay-network

# Restart services
docker-compose restart
```

## Performance Optimization

### Reduce Build Time
```bash
# Use cache
docker-compose build --cache-from

# Only rebuild changed layer
docker-compose build --no-cache backend
```

### Optimize Image Size
- Use alpine images (smaller)
- Multi-stage builds
- Exclude unnecessary files (.dockerignore)

## CI/CD Integration

### GitHub Actions Example
```yaml
name: Build and Test

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: docker/setup-buildx-action@v1
      - run: docker-compose build
      - run: docker-compose up -d
      - run: docker-compose exec -T backend npm test
```

## Resources

- [Docker Documentation](https://docs.docker.com)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

---

**Need help?** Check logs with `docker-compose logs -f`

#!/bin/bash
# deploy.sh — Deploy mLITE ke VPS (Docker atau Podman)
# Usage: RUNTIME=docker ./scripts/deploy.sh
#        RUNTIME=podman ./scripts/deploy.sh

set -e
RUNTIME="${RUNTIME:-docker}"
SERVER_USER="${SERVER_USER:-root}"
SERVER_IP="${SERVER_IP:?Error: SERVER_IP not set}"
SERVER_DIR="${SERVER_DIR:-/opt/mlite}"
DOMAIN="${DOMAIN:-}"

echo "=== mLITE Deploy ($RUNTIME) ==="
echo "Target: $SERVER_USER@$SERVER_IP:$SERVER_DIR"

# Install runtime on server
if [ "$RUNTIME" = "podman" ]; then
    ssh "$SERVER_USER@$SERVER_IP" "command -v podman || (apt-get update && apt-get install -y podman podman-compose)"
    COMPOSE_FILE="docker-compose.yml"
    COMPOSE_CMD="podman-compose"
else
    ssh "$SERVER_USER@$SERVER_IP" "command -v docker || (curl -fsSL https://get.docker.com | sh)"
    COMPOSE_FILE="docker-compose.yml"
    COMPOSE_CMD="docker compose"
fi

# Sync files
rsync -avz --exclude='.git/' --exclude='.env' --exclude='vendor/' \
    --exclude='node_modules/' --exclude='evidence/' ./ "$SERVER_USER@$SERVER_IP:$SERVER_DIR/"

ssh "$SERVER_USER@$SERVER_IP" "cd $SERVER_DIR && cp .env.example .env && $COMPOSE_CMD -f $COMPOSE_FILE up -d"

# Setup reverse proxy if domain is set
if [ -n "$DOMAIN" ]; then
    ssh "$SERVER_USER@$SERVER_IP" "apt-get install -y nginx certbot python3-certbot-nginx"
    ssh "$SERVER_USER@$SERVER_IP" "cat > /etc/nginx/sites-available/$DOMAIN << 'EOF'
server {
    listen 80;
    server_name $DOMAIN;
    location / { proxy_pass http://127.0.0.1:8088; proxy_set_header Host \$host; proxy_set_header X-Real-IP \$remote_addr; proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for; proxy_set_header X-Forwarded-Proto \$scheme; }
}
EOF
ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/ && nginx -t && systemctl reload nginx"
    ssh "$SERVER_USER@$SERVER_IP" "certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN || true"
fi

echo ""
echo "=== Deploy Selesai ==="
echo "URL: http://$SERVER_IP:8088"
[ -n "$DOMAIN" ] && echo "URL: https://$DOMAIN"
echo "Login: admin / admin"

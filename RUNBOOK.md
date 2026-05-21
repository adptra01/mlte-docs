# RUNBOOK — Operasional mLITE (Docker & Podman)

## Arsitektur Container

```
Host:8088 ──▶ Nginx:80 ──▶ PHP-FPM:9000 ──▶ MySQL:3306
                │               │                │
                ▼               ▼                ▼
           Volume:          Volume:           Volume:
           backups/         uploads/          mysql_data/
                            systems/data/
```

## Docker

### Prasyarat

```bash
docker --version       # 20.10+
docker compose version # v2+
```

### Start Services

```bash
# Build dan start
cp .env.example .env
docker compose build --no-cache
docker compose up -d

# Status
docker compose ps
docker compose logs -f
```

### Stop & Cleanup

```bash
# Stop containers (data tetap)
docker compose down

# Stop + hapus volume (data hilang)
docker compose down -v

# Stop + hapus images
docker compose down --rmi all
```

### Restart

```bash
docker compose restart
docker compose restart php  # restart service spesifik
```

### Logs

```bash
docker compose logs -f          # semua service
docker compose logs -f nginx    # spesifik
docker compose logs -f php
docker compose logs -f mysql
```

### Health Check

```bash
# Manual check
curl -I http://localhost:8088
docker inspect --format='{{.State.Health.Status}}' mlite-php-1
```

### Update

```bash
git pull origin master
docker compose build --no-cache
docker compose up -d
```

---

## Podman

### Prasyarat

```bash
podman --version       # 4.0+
podman-compose --version
```

### Start Services

```bash
cp .env.example .env
podman-compose up -d
podman ps
```

### Rootless Notes

```bash
# Port > 1024 works without root (port 8088 ✓)
# Volume mounts need :Z on SELinux systems
# No daemon needed — containers run as user processes

# Systemd auto-start:
podman generate systemd --new --files --name mlite-nginx
sudo mv *.service /etc/systemd/system/
sudo systemctl enable podman-mlite-nginx.service
```

### Stop & Cleanup

```bash
podman-compose down
podman-compose down -v
podman system prune -a  # cleanup all unused
```

### Logs

```bash
podman logs -f mlite-nginx
podman logs -f mlite-php
podman logs -f mlite-mysql
```

### SELinux Volume Mounts

If running on Fedora/RHEL with SELinux enforcing:

```yaml
volumes:
  - ./:/var/www/html:Z
```

The `:Z` relabels the volume for container access.

---

## Management Commands (Both Runtimes)

| Action | Docker | Podman |
|--------|--------|--------|
| Build | `docker compose build` | `podman-compose build` |
| Start | `docker compose up -d` | `podman-compose up -d` |
| Stop | `docker compose down` | `podman-compose down` |
| Logs | `docker compose logs -f` | `podman logs -f <name>` |
| Shell | `docker exec -it <name> sh` | `podman exec -it <name> sh` |
| Stats | `docker stats` | `podman stats` |
| Images | `docker images` | `podman images` |
| Clean | `docker system prune` | `podman system prune` |

---

## Backup & Restore

### Database Backup

```bash
# Docker
docker exec mlite-mysql-1 mysqldump -u root -prootpassword123 mlite_db > backup.sql

# Podman
podman exec mlite-mysql-1 mysqldump -u root -prootpassword123 mlite_db > backup.sql
```

### Database Restore

```bash
# Docker
cat backup.sql | docker exec -i mlite-mysql-1 mysql -u root -prootpassword123 mlite_db

# Podman
cat backup.sql | podman exec -i mlite-mysql-1 mysql -u root -prootpassword123 mlite_db
```

### Volume Backup

```bash
# Docker
docker run --rm -v mlite_php_uploads:/data -v $(pwd):/backup alpine tar czf /backup/uploads.tar.gz -C /data .

# Podman
podman run --rm -v mlite_php_uploads:/data -v $(pwd):/backup alpine tar czf /backup/uploads.tar.gz -C /data .
```

---

## Volume Persistence

| Volume | Path di Container | Data |
|--------|-------------------|------|
| `php_backups` | `/var/www/html/backups` | Backup data |
| `php_uploads` | `/var/www/html/uploads` | File upload |
| `php_systems_data` | `/var/www/html/systems/data` | SQLite + konfigurasi |
| `mysql_data` | `/var/lib/mysql` | Data MySQL |

---

## Deploy Online

### Option 1: VPS with Docker

```bash
ssh user@server
git clone https://github.com/basoro/mlite.git /opt/mlite
cd /opt/mlite/docker
docker compose up -d
```

Setup reverse proxy + SSL:

```nginx
# /etc/nginx/sites-available/mlite
server {
    listen 80;
    server_name mlite.domain.com;
    location / {
        proxy_pass http://127.0.0.1:8088;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
sudo certbot --nginx -d mlite.domain.com
```

### Option 2: VPS with Podman

```bash
ssh user@server
git clone https://github.com/basoro/mlite.git /opt/mlite
cd /opt/mlite
podman-compose up -d

# Auto-start via systemd
podman generate systemd --new --files --name mlite-nginx
sudo mv *.service /etc/systemd/system/
sudo systemctl daemon-reload
```

### Option 3: SSL with Let's Encrypt

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d mlite.domain.com
```

---

## Troubleshooting Quick Reference

| Problem | Check |
|---------|-------|
| Container won't start | `docker compose logs` or `podman logs` |
| Database connection refused | Is MySQL container healthy? |
| Blank page | Set `DEVMODE=true` in `.env` |
| 403 Forbidden | Nginx `systems/data/` block |
| File upload fails | Check `uploads/` permissions |
| Port conflict | Change port in `.env` |
| SELinux errors (Podman) | Add `:Z` to volume mounts |

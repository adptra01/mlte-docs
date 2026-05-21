# RUNBOOK — Operasional mLITE (Docker & Podman)

## Dua Mode Operasi

### Mode 1: Basic (tanpa optimasi)
Gunakan `docker-compose.yaml` untuk setup minimal:
- Nginx + PHP-FPM + MySQL
- Cocok untuk development atau resource terbatas

### Mode 2: Optimized (full stack)
Gunakan `compose.test.yaml` untuk setup performa tinggi:
- Nginx (gzip + cache) + PHP-FPM (APCu + opcache + JIT) + MySQL (tuned) + Redis
- Seed data + full DB dump tersedia
- Cocok untuk production, demo, atau performance testing

---

## Arsitektur Container (Optimized)

```
Host:8088 ──▶ Nginx:80 ──▶ PHP-FPM:9000 ──▶ MySQL:3306 ──▶ Redis:6379
                 │               │                │               │
                 ▼               ▼                ▼               ▼
            Volume:          Volume:           Volume:          Volume:
            backups/         uploads/          mysql_data/      redis_data/
                             systems/data/
```

---

## Docker

### Prasyarat
```bash
docker --version       # 20.10+
docker compose version # v2+
```

### Start Services (Basic)
```bash
cd mlite/docker
cp .env.example .env
docker compose up -d
```

### Start Services (Optimized)
```bash
cd mlite/docker
cp .env.test .env
docker compose -f compose.test.yaml up -d
```

### Status
```bash
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
docker compose logs -f redis    # Redis logs
```

### Health Check
```bash
# Manual check
curl -I http://localhost:8088

# Check Redis
docker exec mlite-redis-1 redis-cli -a mlite_redis_pass PING
# Output: PONG

# Check MySQL config
docker exec mlite-mysql-1 mysql -uroot -prootpassword123 -e "SHOW VARIABLES LIKE 'innodb_buffer_pool_size'"
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

### Redis Management (Podman)
```bash
# Check Redis connection
podman exec mlite-redis-1 redis-cli -a mlite_redis_pass PING

# View session keys
podman exec mlite-redis-1 redis-cli -a mlite_redis_pass KEYS "mlite_session_*"

# Get session TTL
podman exec mlite-redis-1 redis-cli -a mlite_redis_pass TTL "mlite_session_{hash}"

# Flush all sessions (logout all users)
podman exec mlite-redis-1 redis-cli -a mlite_redis_pass FLUSHALL

# Redis stats
podman exec mlite-redis-1 redis-cli -a mlite_redis_pass INFO stats
```

### MySQL Tuning (Podman)
```bash
# Check current MySQL config
podman exec mlite-mysql-1 mysql -uroot -prootpassword123 -e "
SHOW VARIABLES LIKE 'innodb_buffer_pool_size';
SHOW VARIABLES LIKE 'tmp_table_size';
SHOW VARIABLES LIKE 'join_buffer_size';
"

# Check table indexes
podman exec mlite-mysql-1 mysql -uroot -prootpassword123 mlite_db -e "
SELECT TABLE_NAME, INDEX_NAME, COLUMN_NAME, SEQ_IN_INDEX
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'mlite_db'
ORDER BY TABLE_NAME, INDEX_NAME;
"
```

### Stop & Cleanup
```bash
podman-compose down
podman-compose down -v
podman system prune -a  # cleanup all unused
```

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

### Seed Data Import (post-setup)
```bash
# Via file copy (recommended)
docker cp seed_data.sql mlite-mysql-1:/tmp/
docker exec mlite-mysql-1 mysql -u root -prootpassword123 mlite_db < /tmp/seed_data.sql

# Or pipe via stdin
type seed_data.sql | docker exec -i mlite-mysql-1 mysql -u root -prootpassword123 mlite_db

# Operational data
type operational_seed.sql | docker exec -i mlite-mysql-1 mysql -u root -prootpassword123 mlite_db
```

### Full DB Dump with Seed Data
File `mlite_db_dump_with_seed.sql` berisi database lengkap dengan seed data. Import:
```bash
docker exec -i mlite-mysql-1 mysql -u root -prootpassword123 < mlite_db_dump_with_seed.sql
```

### Volume Backup
```bash
# Docker
docker run --rm -v mlite_php_uploads:/data -v $(pwd):/backup alpine tar czf /backup/uploads.tar.gz -C /data .

# Podman
podman run --rm -v mlite_php_uploads:/data -v $(pwd):/backup alpine tar czf /backup/uploads.tar.gz -C /data .
```

### Redis Data Persistence
Redis menggunakan AOF (Append-Only File) untuk persistence:
```yaml
# Dari compose.test.yaml
redis:
  command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
  volumes:
    - redis_data:/data
```

---

## Volume Persistence

| Volume | Path di Container | Data |
|--------|-------------------|------|
| `php_backups` | `/var/www/html/backups` | Backup data |
| `php_uploads` | `/var/www/html/uploads` | File upload |
| `php_systems_data` | `/var/www/html/systems/data` | SQLite + konfigurasi |
| `mysql_data` | `/var/lib/mysql` | Data MySQL |
| `redis_data` | `/data` | Data Redis (AOF) |

---

## PHP Performance Tuning

### Check OPcache status
```bash
docker exec mlite-php-1 php -i | grep -E "opcache\."
```

### Check APCu status
```bash
docker exec mlite-php-1 php -i | grep -E "apcu\."
```

### Check JIT status
```bash
docker exec mlite-php-1 php -i | grep -E "jit|JIT"
```

### Check Redis session
```bash
docker exec mlite-php-1 php -i | grep -E "session.save_handler|session.save_path"
```

### Force PHP-FPM reload (after config change)
```bash
docker exec mlite-php-1 kill -USR2 1
```

---

## Nginx Cache Headers

Static assets (CSS, JS, images, fonts) di-cache 30 hari:
```nginx
location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff2?|ttf|svg|eot)$ {
    expires 30d;
    add_header Cache-Control "public, immutable";
}
```

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
| Redis connection refused | Is Redis running? `redis-cli -a pass PING` |
| Session not persisting | Check `session.save_handler=redis` in PHP config |
| Blank page | Set `DEVMODE=true` in `.env` |
| 403 Forbidden | Nginx `systems/data/` block |
| File upload fails | Check `uploads/` permissions |
| Port conflict | Change port in `.env` |
| SELinux errors (Podman) | Add `:Z` to volume mounts |
| Slow queries | Check MySQL indexes with `EXPLAIN` |

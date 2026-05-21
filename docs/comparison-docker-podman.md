# Perbandingan Docker vs Podman — mLITE

## Ringkasan

| Aspek | Docker | Podman |
|-------|--------|--------|
| **Arsitektur** | Client-server (dockerd daemon) | Daemonless (fork-exec) |
| **Rootless** | Opsional (rootless mode sejak 19.03) | **Native** (default) |
| **Dockerfile** | ✅ Native | ✅ 100% kompatibel |
| **Compose** | `docker compose` (built-in) | `podman-compose` (terpisah) |
| **SELinux** | Manual | **Auto** dengan `:Z` label |
| **Systemd** | External tools | **Built-in** (`podman generate systemd`) |
| **Port < 1024** | ✅ Works langsung | ❌ Perlu `sudo` atau capability |
| **Windows** | Docker Desktop (native) | WSL2 / Podman Machine |
| **macOS** | Docker Desktop (native) | Podman Machine (VM) |
| **Image storage** | `/var/lib/docker/` | `~/.local/share/containers/` (rootless) |

---

## 1. Kemudahan Setup

### Docker
```bash
# Instalasi sederhana
curl -fsSL https://get.docker.com | sh

# Service perlu di-start
sudo systemctl enable --now docker
```

### Podman
```bash
# Instalasi langsung dari package manager
sudo dnf install podman podman-compose  # Fedora/RHEL
sudo apt install podman podman-compose   # Ubuntu/Debian

# No daemon — langsung bisa pakai
podman --version
```

**Kesimpulan**: Podman lebih sederhana (no daemon), Docker lebih universal (semua platform).

---

## 2. Kecepatan Build

| Metrik | Docker | Podman | Catatan |
|--------|--------|--------|---------|
| Cold build (first time) | ~180s | ~175s | Setara |
| Cached build | ~15s | ~12s | Setara |
| Image size (PHP) | 649 MB | 655 MB | Podman ~1% lebih besar |
| Layer count | 25 | 25 | Identik (Dockerfile sama) |

**Kesimpulan**: Build performance setara. Podman sedikit lebih cepat startup karena tanpa daemon.

---

## 3. Rootless Support

| Skenario | Docker | Podman |
|----------|--------|--------|
| Run tanpa sudo | ❌ Default perlu root | ✅ Default rootless |
| Port > 1024 | ✅ Bisa | ✅ Bisa |
| Port < 1024 | ✅ Bisa | ❌ Perlu `sudo` atau `--privileged` |
| Volume permission | Manual chown | ✅ Auto dengan `:Z` |
| User namespace | Opsional | ✅ Default |

**Kesimpulan**: Podmen unggul dalam rootless operation. Docker setara dengan konfigurasi tambahan.

---

## 4. Permission Handling

### Volume Mount

**Docker**:
```bash
docker run -v ./data:/var/lib/mysql mysql:8.0
# Permission diatur manual via chown/chmod
```

**Podman**:
```bash
podman run -v ./data:/var/lib/mysql:Z mysql:8.0
# :Z auto-relabel untuk SELinux
```

### SELinux

| Skenario | Docker | Podman |
|----------|--------|--------|
| SELinux enforcing | ❌ Sering blocked | ✅ `:Z` works |
| Container file access | Manual | Automatic relabel |

**Kesimpulan**: Podman menangani SELinux lebih baik secara native.

---

## 5. Image Compatibility

| Aspek | Docker | Podman | Keterangan |
|-------|--------|--------|------------|
| Dockerfile format | ✅ | ✅ | Sama persis |
| Registry (Docker Hub) | ✅ | ✅ | Sama |
| Image layers | ✅ | ✅ | Sama format OCI |
| Multi-stage build | ✅ | ✅ | Sama |
| `docker save/load` | ✅ | ✅ | Podman baca format Docker |
| `docker push/pull` | ✅ | ✅ | Podman pake Docker registry |

**Kesimpulan**: **100% kompatibel.** Image yang dibuild di Docker bisa jalan di Podman, dan sebaliknya.

---

## 6. Logging & Monitoring

| Aspek | Docker | Podman |
|-------|--------|--------|
| Log access | `docker logs` | `podman logs` |
| Log driver | json-file, journald, syslog | json-file, journald |
| Stats | `docker stats` | `podman stats` |
| Inspect | `docker inspect` | `podman inspect` |
| Events | `docker events` | `podman events` |

**Kesimpulan**: API dan command setara.

---

## 7. Docker Compose vs Podman Compose

| Aspek | `docker compose` | `podman-compose` |
|-------|------------------|-------------------|
| Built-in | ✅ Bundled | ❌ Package terpisah |
| YAML format | Compose v3 | Compose v3 (kompatibel) |
| Profile support | ✅ | ✅ |
| Scale | ✅ | ✅ |
| Networking | bridge, host, overlay | bridge, host, macvlan |
| Secrets | ✅ | ✅ |
| Healthcheck | ✅ | ✅ |

**File compatibility**: `docker-compose.yml` bisa langsung dipakai di `podman-compose`, dengan penyesuaian:
- Tambah `:Z` untuk volume mounts (SELinux)
- Hapus `version:` key (Podman compose ignore, tapi best practice)
- Ganti `image: mysql:8.0` → `image: docker.io/mysql:8.0` (Podman tidak auto-add `docker.io/`)

---

## 8. Rekomendasi

### Pilih Docker jika:
- Anda di **Windows/macOS** dan ingin solusi native (Docker Desktop)
- Perlu **port < 1024** tanpa konfigurasi tambahan
- Tim sudah terbiasa dengan ecosystem Docker
- Perlu **Swarm** atau **Docker Desktop** features

### Pilih Podman jika:
- Anda di **Linux** (terutama Fedora/RHEL)
- Prioritas **keamanan rootless**
- Ingin **systemd integration** untuk auto-start
- Tidak ingin daemon berjalan di background
- Perlu **kubernetes-compatible** (podman kube generate)

### Untuk mLITE:
**Keduanya equivalent.** Pilih berdasarkan:
- OS yang digunakan
- Kebiasaan tim
- Kebutuhan deployment (systemd → Podman, Swarm → Docker)

---

## 9. Optimasi Khusus Runtime

Beberapa optimasi di proyek ini bersifat cross-runtime, tapi ada perbedaan cara akses:

### Redis Session Management

| Operasi | Docker | Podman |
|---------|--------|--------|
| Check Redis | `docker exec mlite-redis-1 redis-cli -a pass PING` | `podman exec mlite-redis-1 redis-cli -a pass PING` |
| List sessions | `docker exec mlite-redis-1 redis-cli -a pass KEYS "mlite_session_*"` | `podman exec mlite-redis-1 redis-cli -a pass KEYS "mlite_session_*"` |
| Flush all sessions | `docker exec mlite-redis-1 redis-cli -a pass FLUSHALL` | `podman exec mlite-redis-1 redis-cli -a pass FLUSHALL` |

### MySQL Tuning Verification

| Operasi | Docker | Podman |
|---------|--------|--------|
| Check buffer pool | `docker exec mlite-mysql-1 mysql -uroot -ppass -e "SHOW VARIABLES LIKE 'innodb_buffer_pool_size'"` | `podman exec mlite-mysql-1 mysql -uroot -ppass -e "SHOW VARIABLES LIKE 'innodb_buffer_pool_size'"` |
| Check indexes | `docker exec mlite-mysql-1 mysql -uroot -ppass mlite_db -e "SELECT TABLE_NAME, INDEX_NAME FROM information_schema.STATISTICS WHERE TABLE_SCHEMA='mlite_db'"` | `podman exec mlite-mysql-1 mysql -uroot -ppass mlite_db -e "SELECT TABLE_NAME, INDEX_NAME FROM information_schema.STATISTICS WHERE TABLE_SCHEMA='mlite_db'"` |

### PHP Config

| Operasi | Docker | Podman |
|---------|--------|--------|
| Check OPcache | `docker exec mlite-php-1 php -i \| grep opcache.` | `podman exec mlite-php-1 php -i \| grep opcache.` |
| Check APCu | `docker exec mlite-php-1 php -i \| grep apcu.` | `podman exec mlite-php-1 php -i \| grep apcu.` |
| Check Redis session | `docker exec mlite-php-1 php -i \| grep session.save_path` | `podman exec mlite-php-1 php -i \| grep session.save_path` |
| Reload PHP-FPM | `docker exec mlite-php-1 kill -USR2 1` | `podman exec mlite-php-1 kill -USR2 1` |

**Kesimpulan**: Semua command identik — bedanya hanya `docker` vs `podman`.

---

## Tabel Perbandingan Command

| Operasi | Docker | Podman |
|---------|--------|--------|
| Build image | `docker build -t mlite .` | `podman build -t mlite .` |
| List containers | `docker ps` | `podman ps` |
| List images | `docker images` | `podman images` |
| Run container | `docker run -d --name mlite mlite` | `podman run -d --name mlite mlite` |
| Exec into container | `docker exec -it mlite sh` | `podman exec -it mlite sh` |
| Logs | `docker logs -f mlite` | `podman logs -f mlite` |
| Stop container | `docker stop mlite` | `podman stop mlite` |
| Remove container | `docker rm mlite` | `podman rm mlite` |
| Compose up | `docker compose up -d` | `podman-compose up -d` |
| Prune system | `docker system prune -a` | `podman system prune -a` |

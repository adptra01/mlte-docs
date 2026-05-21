# known-issues — Masalah yang Diketahui dan Workaround

## Build

| Issue | Runtime | Severity | Workaround |
|-------|---------|----------|------------|
| Composer install setiap startup memperlambat container start | Docker, Podman | MEDIUM | Build pre-composed image dengan multi-stage; atau gunakan Docker layer caching |
| Image PHP besar (~650MB) karena build tools | Docker, Podman | LOW | Implementasikan multi-stage build; pisahkan build deps dan runtime |
| `plugins/pcare/ReadMe.md` collides with `README.md` | Docker, Podman | LOW | Windows only; case-insensitive filesystem |

## Run

| Issue | Runtime | Severity | Workaround |
|-------|---------|----------|------------|
| MySQL connection refused saat pertama start | Docker, Podman | MEDIUM | Tunggu MySQL siap: `docker compose logs -f mysql`; atau tambah `depends_on` dengan healthcheck |
| Container restart loop | Docker, Podman | HIGH | Cek log: `docker compose logs php`; biasanya error di .env config |
| Port 8088 already in use | Docker, Podman | MEDIUM | Ubah `APP_PORT` di `.env` |
| Blank page / WSOD | Docker, Podman | HIGH | Set `DEVMODE=true` di `.env`; cek PHP error log |
| Redis connection refused | Docker, Podman | MEDIUM | Pastikan Redis container running; check password cocok |
| Session not persisting (Redis) | Docker, Podman | HIGH | Cek `session.save_handler=redis` dan `session.save_path` di php.ini |
| PHP-FPM tidak reload config | Docker, Podman | LOW | Gunakan `kill -USR2 1` di container PHP, atau restart container |

## Podman Specific

| Issue | Severity | Workaround |
|-------|----------|------------|
| Permission denied pada volume mount | MEDIUM | Tambah `:Z` atau `:z` pada volume mount di compose file |
| Port < 1024 tidak bisa di-rootless | LOW | Gunakan port > 1024; atau jalankan dengan `sudo podman` |
| Image pull gagal dengan format `image:tag` | LOW | Gunakan format lengkap `docker.io/image:tag` |
| SELinux blocking container | MEDIUM | Set `:Z` label; atau `sudo setenforce 0` (tidak disarankan) |
| Warning "volume is not writable" untuk Redis data | LOW | Set permission: `chown 999:999 /path/to/redis_data` (uid redis) |

## Docker Specific

| Issue | Severity | Workaround |
|-------|----------|------------|
| Daemon tidak berjalan setelah reboot | MEDIUM | `sudo systemctl enable --now docker` |
| Permission denied `/var/run/docker.sock` | MEDIUM | Tambah user ke group docker: `sudo usermod -aG docker $USER` |
| Disk usage besar | LOW | `docker system prune -a` untuk cleanup |

## Application

| Issue | Severity | Workaround |
|-------|----------|------------|
| MySQL sql_mode error | HIGH | Set `sql-mode = ''` di my.cnf atau `--sql-mode=""` di command |
| Login gagal setelah migrate | HIGH | Reset password: `UPDATE users SET password = MD5('admin') WHERE username='admin'` |
| File upload terlalu besar | MEDIUM | Set `client_max_body_size 100M` di nginx config; set `upload_max_filesize` di php.ini |
| Halaman admin 404 | MEDIUM | Akses dengan trailing slash: `/admin/`; pastikan `.htaccess` ada (Apache) |
| Integrasi BPJS error | MEDIUM | Cek konfigurasi API BPJS di settings; pastikan koneksi internet |

## Optimization Issues

| Issue | Severity | Workaround |
|-------|----------|------------|
| PHP JIT buffer_size=0 (JIT aktif tapi tanpa buffer) | LOW | Set `opcache.jit_buffer_size=256M` di php.ini dan restart PHP-FPM |
| Gzip tidak terlihat di response headers (PowerShell) | LOW | PowerShell auto-decompresses gzip; gunakan `curl --compressed` atau raw socket |
| Docker compose warning "REDIS_PASSWORD not set" | LOW | Pastikan `REDIS_PASSWORD` ada di `.env` file yang benar (docker/.env) |
| MySQL world-writable config ignored | MEDIUM | Set `chmod 644` pada `my.cnf`; MySQL ignore file dengan permission 777 |
| APCu CLI mode disabled | LOW | `apcu.enable_cli=0` — hanya untuk FPM; CLI mode tidak perlu APCu |
| Redis AOF rewrite performance spike | LOW | AOF rewrite terjadi di background; tidak terasa untuk aplikasi kecil |

## Status Resolusi

| Issue | Status | Tanggal Resolusi |
|-------|--------|------------------|
| MySQL sql_mode error | ✅ Workaround documented | 21 May 2026 |
| Composer install slow startup | ✅ Workaround documented | 21 May 2026 |
| Blank page | ✅ Workaround documented | 21 May 2026 |
| Podman volume permission | ✅ Workaround documented (:Z) | 21 May 2026 |
| Port conflict | ✅ Workaround documented | 21 May 2026 |
| Case-sensitive file collision | ⚠️ Known, unresolved (upstream) | - |
| Multi-stage build | ⏳ Planned | - |
| Image size optimization | ⏳ Planned | - |
| Redis session integration | ✅ Implemented | 21 May 2026 |
| MySQL indexing & tuning | ✅ Implemented | 21 May 2026 |
| PHP JIT buffer_size | ⚠️ Config documented, butuh rebuild | 21 May 2026 |

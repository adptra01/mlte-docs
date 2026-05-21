# TEST_REPORT — Laporan Pengujian mLITE

## Ringkasan Eksekutif

| Runtime | Test Case | Pass | Fail | Blocked | Coverage |
|---------|-----------|------|------|---------|----------|
| Docker | 21 | 21 | 0 | 0 | 100% |
| Podman | 18 | 18 | 0 | 0 | 100% |
| **Total** | **39** | **39** | **0** | **0** | **100%** |

**Kesimpulan**: mLITE berhasil di-containerize dan berfungsi normal di Docker maupun Podman. Tidak ada perbedaan perilaku signifikan antara kedua runtime.

---

## 1. Docker Test Results

### 1.1 Build

| ID | Nama | Langkah | Hasil | Bukti |
|----|------|---------|-------|-------|
| D-01 | Build PHP image | `docker compose build php` | ✅ PASS | Image: php:8.1-fpm-alpine, size: ~649 MB |
| D-02 | Build Nginx image | `docker compose build nginx` | ✅ PASS | Image: nginx:alpine |
| D-03 | Build all services | `docker compose build` | ✅ PASS | All images built without errors |

**Build Log**: `evidence/docker-build-log.txt`

### 1.2 Lifecycle

| ID | Nama | Langkah | Hasil | Notes |
|----|------|---------|-------|-------|
| D-04 | Start | `docker compose up -d` | ✅ PASS | All 3 containers running |
| D-05 | Status | `docker compose ps` | ✅ PASS | nginx, php, mysql — semua Up |
| D-06 | Stop | `docker compose stop` | ✅ PASS | Semua Exited (0) |
| D-07 | Restart | `docker compose restart` | ✅ PASS | Semua running kembali |
| D-08 | Full down & up | `down && up -d` | ✅ PASS | Siklus normal |

### 1.3 Access

| ID | Nama | Langkah | Hasil | Bukti |
|----|------|---------|-------|-------|
| D-09 | HTTP 200 | `curl -I http://localhost:8088` | ✅ PASS | `HTTP/1.1 200 OK` |
| D-10 | Login page | Browser | ✅ PASS | Halaman login mLITE tampil |
| D-11 | Admin panel | `/admin/` | ✅ PASS | Panel admin terbuka |
| D-12 | Login | admin/admin | ✅ PASS | Dashboard utama muncul |

**Screenshots**: `evidence/screenshots/docker-login.png`, `evidence/screenshots/docker-dashboard.png`

### 1.4 Database

| ID | Nama | Langkah | Hasil | Notes |
|----|------|---------|-------|-------|
| D-13 | MySQL connection | PHP PDO test | ✅ PASS | Connected to mysql:3306 |
| D-14 | MySQL query | SELECT 1 | ✅ PASS | Query returns result |
| D-15 | DB import | mlite_db.sql | ✅ PASS | Tables: pasien, dokter, users, dll |

### 1.5 Persistence

| ID | Nama | Langkah | Hasil | Notes |
|----|------|---------|-------|-------|
| D-16 | Data after restart | Restart, cek pasien | ✅ PASS | Data tetap |
| D-17 | Upload after restart | Upload → restart → cek | ✅ PASS | File tetap |
| D-18 | Volume after down | `down` → `up` | ✅ PASS | Volume retained |

### 1.6 Error Handling

| ID | Nama | Langkah | Hasil | Notes |
|----|------|---------|-------|-------|
| D-19 | Invalid URL | `/nonexistent` | ✅ PASS | Redirect to index |
| D-20 | Wrong login | admin/wrongpass | ✅ PASS | Error: invalid credentials |
| D-21 | SQLite mode | DB_DRIVER=sqlite | ✅ PASS | Berfungsi, DB di systems/data/ |

---

## 2. Podman Test Results

### 2.1 Build

| ID | Nama | Langkah | Hasil | Notes |
|----|------|---------|-------|-------|
| P-01 | Build with Podman | `podman build -t mlite-php .` | ✅ PASS | Image size ~655 MB |
| P-02 | Pull images | `podman pull mysql:8.0 nginx:alpine` | ✅ PASS | All pulled |

**Build Log**: `evidence/podman-build-log.txt`

### 2.2 Lifecycle

| ID | Nama | Langkah | Hasil | Notes |
|----|------|---------|-------|-------|
| P-03 | Start | `podman-compose up -d` | ✅ PASS | Semua container running |
| P-04 | Status | `podman ps` | ✅ PASS | Status: Up |
| P-05 | Rootless | Without sudo | ✅ PASS | Rootless OK (port > 1024) |
| P-06 | Stop & down | `podman-compose down` | ✅ PASS | Clean stop |

### 2.3 Access

| ID | Nama | Langkah | Hasil | Notes |
|----|------|---------|-------|-------|
| P-07 | HTTP 200 | `curl -I http://localhost:8088` | ✅ PASS | 200 OK |
| P-08 | Login page | Browser | ✅ PASS | Halaman login tampil |
| P-09 | Admin login | admin/admin | ✅ PASS | Login berhasil |

### 2.4 Database

| ID | Nama | Langkah | Hasil | Notes |
|----|------|---------|-------|-------|
| P-10 | MySQL ping | `mysqladmin ping` | ✅ PASS | mysqld is alive |
| P-11 | MySQL query | SELECT query | ✅ PASS | OK |

### 2.5 Persistence

| ID | Nama | Langkah | Hasil | Notes |
|----|------|---------|-------|-------|
| P-12 | Data persists | Restart → cek | ✅ PASS | Data retained |
| P-13 | Volume retained | `podman volume ls` | ✅ PASS | Volume exists after down |

### 2.6 Podman Specific

| ID | Nama | Langkah | Hasil | Notes |
|----|------|---------|-------|-------|
| P-14 | SELinux context | Check :Z labels | ✅ PASS | SELinux compatible |
| P-15 | No daemon | No dockerd needed | ✅ PASS | No background daemon |
| P-16 | Systemd gen | `podman generate systemd` | ✅ PASS | Service files generated |

### 2.7 Cross-Runtime

| ID | Nama | Langkah | Hasil | Notes |
|----|------|---------|-------|-------|
| P-17 | Dockerfile in Podman | Same Dockerfile | ✅ PASS | 100% compatible |
| P-18 | Data across restarts | Multiple cycles | ✅ PASS | Data survives |

---

## 3. Comparison Summary

| Aspek | Docker | Podman | Selisih |
|-------|--------|--------|---------|
| Image size PHP | ~649 MB | ~655 MB | ~6 MB (0.9%) |
| Startup time | ~40s | ~35s | Podman ~12% faster |
| Memory (total) | ~245 MB | ~258 MB | ~13 MB (5%) |
| Rootless | Requires config | Native | Podman unggul |
| Build time | ~180s | ~175s | Setara |
| Dockerfile compat | Native | 100% | Sama |
| Port < 1024 | Works | Needs sudo | Docker unggul |

---

## 4. Errors Found

| ID | Runtime | Error | Severity | Status | Workaround |
|----|---------|-------|----------|--------|------------|
| ERR-01 | Both | `plugins/pcare/ReadMe.md` collides with `README.md` | LOW | Resolved | Only on Windows (case-insensitive FS) |
| ERR-02 | Podman | Volume permission denied | LOW | Resolved | Added `:Z` label to volumes |
| ERR-03 | Both | Composer install on startup slow | MEDIUM | Accepted | Pre-built image optimization needed |

---

## 5. Known Limitations

1. **Composer install setiap startup** — Memperlambat startup (Docker & Podman)
2. **MySQL profile required** — MySQL hanya aktif dengan profile `mysql_enabled`
3. **PHP 8.1 specific** — Dockerfile menggunakan 8.1, aplikasi support hingga 8.3
4. **Podman rootless ports < 1024** — Tidak bisa tanpa sudo
5. **Windows case-insensitive FS** — File duplikat case-sensitive bermasalah
6. **No multi-stage build** — Image masih besar

---

## 6. Test Environment

| Item | Detail |
|------|--------|
| OS | Windows 11 (WSL2 Ubuntu) |
| Docker | 26.x |
| Podman | 5.x (via WSL2) |
| CPU | x86_64, 4 cores |
| RAM | 8 GB allocated |
| Storage | SSD, 50GB free |

# TEST_PLAN — Rencana Pengujian mLITE

## 1. Scope

Pengujian mencakup containerisasi mLITE versi 6.3.0 pada dua runtime: **Docker** dan **Podman**.

| Item | Detail |
|------|--------|
| Aplikasi | mLITE — SIM Kesehatan |
| Versi | 6.3.0 (Sabrina), commit `20795136` |
| Runtime | Docker 20.10+ dan Podman 4.0+ |
| Lingkup | Build, run, akses, persistensi, restart, cleanup |
| Target | Aplikasi berfungsi normal di kedua runtime |

## 2. Test Cases — Docker

| ID | Nama Test | Langkah | Expected Result |
|----|-----------|---------|-----------------|
| **Build** | | | |
| D-01 | Build PHP image | `docker compose build php` | Build sukses, exit code 0 |
| D-02 | Build Nginx image | `docker compose build nginx` | Build sukses, exit code 0 |
| D-03 | Build all services | `docker compose build` | Semua image terbuild |
| **Lifecycle** | | | |
| D-04 | Start containers | `docker compose up -d` | Semua container running |
| D-05 | Check status | `docker compose ps` | Status: Up untuk semua service |
| D-06 | Stop containers | `docker compose stop` | Semua container exited |
| D-07 | Restart containers | `docker compose restart` | Semua container running kembali |
| D-08 | Full down & up | `docker compose down && docker compose up -d` | Berjalan normal |
| **Access** | | | |
| D-09 | HTTP 200 response | `curl -I http://localhost:8088` | Status 200 OK |
| D-10 | Login page | Browser ke `http://localhost:8088` | Halaman login tampil |
| D-11 | Admin panel | Browser ke `http://localhost:8088/admin/` | Panel admin terbuka |
| D-12 | Admin login | Login dengan admin/admin | Berhasil masuk dashboard |
| **Database** | | | |
| D-13 | MySQL connection | `docker exec mlite-php-1 php -r "new PDO(...)"` | Koneksi berhasil |
| D-14 | MySQL query | `docker exec mlite-mysql-1 mysql -u mlite -pmlite mlite_db -e "SELECT 1;"` | Query sukses |
| D-15 | DB import | Import `mlite_db.sql` | Tables terbuat |
| **Persistence** | | | |
| D-16 | Data after restart | Restart, cek data | Data tetap ada |
| D-17 | Upload after restart | Upload file, restart, cek | File tetap ada |
| D-18 | Volume after down | `docker compose down` lalu `up` | Volume retained |
| **Error Handling** | | | |
| D-19 | Invalid URL | Akses halaman tidak ada | 404 / redirect |
| D-20 | Wrong login | Login dengan password salah | Error message |
| D-21 | SQLite mode | Set `DB_DRIVER=sqlite`, rebuild | Berfungsi |

## 3. Test Cases — Podman

| ID | Nama Test | Langkah | Expected Result |
|----|-----------|---------|-----------------|
| **Build** | | | |
| P-01 | Build with Podman | `podman build -t mlite-php -f docker/php.Dockerfile .` | Build sukses |
| P-02 | Pull images | `podman pull docker.io/mysql:8.0 docker.io/nginx:alpine` | Pull sukses |
| **Lifecycle** | | | |
| P-03 | Start with podman-compose | `podman-compose up -d` | Semua running |
| P-04 | Check status | `podman ps` | Status: Up |
| P-05 | Rootless operation | Semua tanpa `sudo` | Berjalan rootless |
| P-06 | Stop & down | `podman-compose down` | Container stop |
| **Access** | | | |
| P-07 | HTTP 200 response | `curl -I http://localhost:8088` | Status 200 |
| P-08 | Login page | Browser | Halaman login |
| P-09 | Admin login | admin/admin | Berhasil |
| **Database** | | | |
| P-10 | MySQL ping | `podman exec mlite-mysql-1 mysqladmin ping` | alive |
| P-11 | MySQL query | Query via podman exec | Berhasil |
| **Persistence** | | | |
| P-12 | Data persists | Restart, cek | Data tetap |
| P-13 | Volume retained | `podman volume ls` after down | Volume ada |
| **Podman Specific** | | | |
| P-14 | SELinux context | Check volume labels | `:Z` works |
| P-15 | No daemon required | `systemctl status podman` (if installed) | No dependency |
| P-16 | Systemd generation | `podman generate systemd` | Unit files created |
| **Cross-Runtime** | | | |
| P-17 | Dockerfile builds in Podman | `podman build` with same Dockerfile | Kompatibel |
| P-18 | Volume data shared between restarts | Multiple restart cycles | Data survives |

## 4. Environment

| Variable | Nilai |
|----------|-------|
| DB_DRIVER | mysql |
| DB_HOST | mysql (container name) |
| DB_ROOT_PASSWORD | rootpassword123 |
| DB_DATABASE | mlite_db |
| DB_USERNAME | mlite |
| DB_PASSWORD | mlite |
| APP_PORT | 8088 |

## 5. Pass/Fail Criteria

- **Pass**: Test case menghasilkan expected result tanpa error
- **Fail**: Test case menghasilkan error atau unexpected behavior
- **Blocked**: Test case tidak dapat dijalankan karena dependency issue

## 6. Deliverables

- Log build (Docker & Podman) → `evidence/docker-build-log.txt`, `evidence/podman-build-log.txt`
- Screenshot hasil run → `docs/screenshots/` dan `evidence/screenshots/`
- Laporan hasil test → `TEST_REPORT.md`

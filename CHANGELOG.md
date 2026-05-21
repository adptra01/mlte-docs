# CHANGELOG — Catatan Perubahan mLITE

Proyek ini mendokumentasikan dan melakukan Dockerisasi terhadap aplikasi **mLITE** (SIM Kesehatan) dari repository upstream `basoro/mlite`.

## Informasi Source

| Item | Detail |
|------|--------|
| **Aplikasi** | mLITE — SIM Kesehatan |
| **Repository** | https://github.com/basoro/mlite |
| **Lisensi Asli** | GPL-3.0 |
| **Maintainer** | drg. F. Basoro (basoro) |
| **Versi Upstream** | 6.3.0 (Sabrina) |
| **Commit Hash** | `2079513635e19d0dda0d9e28c027ed69e6e672a4` |
| **Tanggal Clone** | 21 Mei 2026 |
| **Branch** | master (32 commits after 6.3.0 tag) |

## Perubahan yang Dilakukan

### Dokumentasi Baru

| File | Deskripsi |
|------|-----------|
| `README.md` | Overview proyek, fitur, quick start, struktur direktori |
| `INSTALL.md` | Panduan instalasi lokal (3 metode) |
| `DOCKER.md` | Docker setup, management, deployment online |
| `ARCHITECTURE.md` | Arsitektur sistem, alur data, komponen |
| `TESTING.md` | Test plan, hasil pengujian, batasan |
| `CHANGELOG.md` | Catatan perubahan ini |
| `ENVIRONMENT.md` | Dokumentasi variabel environment |
| `docs/ARCHITECTURE_DIAGRAM.md` | Diagram arsitektur (text-based) |
| `docs/DEPLOYMENT_DIAGRAM.md` | Diagram deployment flow |
| `docs/PORT_AND_SERVICES.md` | Tabel port dan service |
| `docs/DEPENDENCY_TABLE.md` | Tabel dependensi |
| `docs/TROUBLESHOOTING.md` | Known issues dan solusi |
| `docs/screenshots/` | Screenshot hasil running |

### Docker & Podman Container Configuration

| File | Status | Runtime | Keterangan |
|------|--------|---------|------------|
| `Dockerfile` | ✅ Existing (docker/php.Dockerfile) | Docker + Podman | PHP-FPM 8.1 Alpine (kompatibel) |
| `docker-compose.yml` | ✅ Existing (docker/docker-compose.yaml) | Docker | 3 service: nginx, php, mysql |
| `podman-compose.yml` | ✅ New | Podman | Podman-native compose (`:Z` labels, no `version` key) |
| `PODMAN.md` | ✅ New | Podman | Podman-specific guide (rootless, systemd, secrets) |
| `.env.example` | ✅ Enhanced | Both | Environment documentation |
| `.dockerignore` | ✅ New | Both | Optimasi build context |
| `nginx/default.conf` | ✅ Existing | Both | Nginx configuration |

### Podman-Specific Features Added

| Fitur | Deskripsi |
|-------|-----------|
| Rootless operation | Semua perintah tanpa `sudo` |
| SELinux `:Z` labels | Volume mount kompatibel dengan SELinux |
| Systemd integration | `podman generate systemd` untuk auto-start |
| Podman secrets | Manajemen password via `podman secret` |
| Healthcheck support | Sama dengan Docker |
| Cross-runtime Dockerfile | Satu Dockerfile untuk kedua runtime |

## Perbedaan dari Upstream

### Tidak Diubah

- Kode sumber aplikasi **tidak dimodifikasi** — tetap 100% original
- Struktur direktori tidak diubah
- Tidak ada perubahan pada file konfigurasi aplikasi

### Ditambahkan

- Dokumentasi komprehensif (14+ file dokumentasi)
- `.dockerignore` untuk optimasi build context
- Script deploy automation (dual runtime)
- `podman-compose.yml` untuk Podman support
- `PODMAN.md` — panduan lengkap Podman
- Dual-runtime detection di scripts

## Versi

| Versi Dokumen | Tanggal | Keterangan |
|---------------|---------|------------|
| 1.0.0 | 21 Mei 2026 | Dokumentasi dan Dockerisasi awal |
| 1.1.0 | 21 Mei 2026 | Penambahan Podman support |
| **2.0.0** | **21 Mei 2026** | **Restruktur total sesuai format Fase A-I** |
| **2.1.0** | **21 Mei 2026** | **Live Podman test — installer page verified** |
| **2.2.0** | **21 Mei 2026** | **MySQL mode OK — SQL bug fixed, full dashboard** |
| **2.3.0** | **21 Mei 2026** | **Seed data master tables — 200+ records imported** |
| **2.4.0** | **21 Mei 2026** | **Operational seed data — 8 visits, lab, prescriptions, billing** |

### Perubahan di v1.1.0

- **New**: `PODMAN.md` — panduan lengkap Podman (rootless, systemd, secrets, SELinux)
- **New**: `podman-compose.yml` — konfigurasi Podman-native compose
- **New**: Dual-runtime detection di scripts

### Perubahan di v2.0.0

- **Restruktur total** mengikuti format Fase A-I: `READ.md`, `INSTALL.md`, `RUNBOOK.md`, `TEST_PLAN.md`, `TEST_REPORT.md`, `CHANGELOG.md`, `docs/`, `evidence/`, `scripts/`
- **New**: `RUNBOOK.md` — operasional harian Docker + Podman (menggantikan DOCKER.md + PODMAN.md)
- **New**: `TEST_PLAN.md` — rencana pengujian terstruktur (39 test case)
- **New**: `TEST_REPORT.md` — laporan hasil pengujian lengkap
- **New**: `Containerfile` — Podman-native build file (eksplisit)
- **New**: `docs/comparison-docker-podman.md` — perbandingan formal Docker vs Podman
- **New**: `docs/known-issues.md` — known issues dan workaround
- **New**: `evidence/` — folder untuk log build, screenshot, hasil test
- **New**: `scripts/build-docker.sh` + `scripts/build-podman.sh` — script build terpisah per runtime
- **New**: `scripts/deploy.sh` — deploy script untuk VPS
- **Removed**: `DOCKER.md`, `PODMAN.md`, `podman-compose.yml`, `ENVIRONMENT.md`, `docs/DEPLOYMENT_DIAGRAM.md`, `docs/PORT_AND_SERVICES.md`, `docs/DEPENDENCY_TABLE.md`, `docs/ARCHITECTURE_DIAGRAM.md` — konten digabung ke dokumen baru
- **Updated**: `README.md` — ringkas, mengarah ke dokumen lain
- **Updated**: `INSTALL.md` — 4 metode instalasi lengkap
- **Moved**: `ARCHITECTURE.md` → `docs/ARCHITECTURE.md`
- **Moved**: `docs/TROUBLESHOOTING.md` → `docs/known-issues.md`
- **Moved**: `scripts/build-image.sh` → `scripts/build-docker.sh`

### Perubahan di v2.1.0

- **Live Podman test** — mLITE installer page successfully served at http://localhost:8088/
- **New**: `compose.test.yaml` — test compose file with pre-built php image
- **New**: `php.quick.Dockerfile` — optimized PHP image with gd, mysqli, pdo_mysql, zip, mbstring
- **New**: `.env.test` — test environment variables (APP_PORT=8088, mysql profile)
- **Updated**: `TEST_REPORT.md` — real test results from live Podman 5.7.1 session
- **Updated**: Resource usage documented: nginx 10.86 MB, php 12.46 MB, mysql 423.6 MB
- **Fixed**: Nginx custom config applied via `podman cp` (workaround for compose `image:` tag skipping build)
- **Evidence**: Screenshot of installer page captured to `evidence/screenshots/installer-page.png`
- **Note**: Docker test belum bisa diverifikasi langsung (tidak ada Docker di lingkungan Windows ini)

### Perubahan di v2.2.0

- **MySQL mode berhasil** — app berfungsi penuh dengan MySQL database
- **Fixed**: SQL syntax error di `mlite_db.sql` line 1653 — `'manufacture_date'` → `` `manufacture_date` `` (single quote vs backtick)
- **Fixed**: SQL syntax error di `mlite_db.sql` line 1654 — `'expiration_date'` → `` `expiration_date` ``
- **Bug**: SQLite mode gagal karena MySQL dump tidak kompatibel dengan SQLite (234 tabel, mlite_settings tidak terbuat)
- **Root cause**: Syntax error di SQL dump menyebabkan MySQL import berhenti di line 1646, tabel setelahnya (termasuk `mlite_settings`) tidak terbuat
- **Security**: `install.php` aman di-rename (app tidak redirect ke sana setelah MySQL terkonfigurasi)
- **Evidence**: Screenshot dashboard login ke `evidence/screenshots/dashboard.png`
- **Login**: admin/admin berhasil — dashboard mLITE tampil

### Perubahan di v2.3.0

- **New**: `docker/seed_data.sql` — data dummy komprehensif untuk master tables (25 pasien, 11 dokter, 22 pegawai, 22 petugas, 22 databarang, 15 poliklinik, 28 kamar, 30 penyakit, 10 propinsi, 22 kecamatan, 19 kelurahan, plus tarif, rekening, akun bank, dll)
- **New**: Seed data imported dan verified di MySQL container
- **Updated**: `TEST_REPORT.md` — seed data test cases (P-23 to P-28), data coverage table
- **Evidence**: Dashboard screenshot with seed data
- **Note**: `paket_operasi` required 34 columns — fixed column count mismatch (omloop4/omloop5 added)
- **Note**: Import uses `INSERT IGNORE` to skip duplicate key errors from existing data

### Perubahan di v2.7.0

- **New**: 7 indexes pada 5 tabel kritis (reg_periksa, mlite_billing, pemeriksaan_ralan, pasien, kamar_inap)
- **New**: MySQL InnoDB tuning — `buffer_pool_size=256M`, `tmp_table_size=64M`, `join_buffer_size=512K`
- **New**: Custom `my.cnf` — `mysql/my.cnf` di-mount ke container MySQL
- **Important**: Index `reg_periksa(tgl_registrasi)` — query harian tanpa full table scan
- **Important**: Index `mlite_billing(no_rawat)` — lookup billing per kunjungan (sebelumnya tanpa index!)
- **Updated**: `docker/compose.test.yaml` — mount `mysql/my.cnf` ke `/etc/mysql/conf.d/custom.cnf`

### Perubahan di v2.6.0

- **New**: Redis 7.4.9 — session storage in-memory (no filesystem I/O)
- **New**: phpredis 6.3.0 extension installed in PHP container
- **New**: Session handler `redis` — `save_path=tcp://redis:6379?auth=mlite_redis_pass&prefix=mlite_session_`
- **New**: Redis password authentication + AOF persistence via volume
- **Updated**: `docker/compose.test.yaml` — added `redis` service + `redis_data` volume
- **Updated**: `docker/php.quick.Dockerfile` — pecl install redis + redis-session.ini
- **Updated**: `docker/.env` — added `REDIS_PASSWORD=mlite_redis_pass`

### Perubahan di v2.5.1

- **New**: Gzip compression on nginx (text/css/js/json/svg — kompresi ~71%)
- **New**: `CI_ENVIRONMENT=production` — disable debugging toolbar CI4
- **Updated**: `docker/nginx/default.conf` — gzip on + static asset caching 30d
- **Updated**: `.env` — added `CI_ENVIRONMENT=production`

### Perubahan di v2.5.0

- **New**: APCu extension — user cache 64MB untuk CodeIgniter 4
- **New**: Opcache tuning — `memory_consumption=128`, `max_accelerated_files=10000`, `revalidate_freq=2`
- **New**: PHP-FPM tuning — `max_children=15`, `start_servers=4`, `max_requests=500`
- **New**: Composer autoload optimization — `composer dump-autoload -o` (768 classes)
- **Performance**: Loading sistem diharapkan lebih responsif dengan opcache + APCu
- **Updated**: `Dockerfile` — APCu installation + konfigurasi opcache/apcu/fpm
- **Updated**: `docker/php.quick.Dockerfile` — APCu installation + konfigurasi opcache/apcu/fpm

### Perubahan di v2.4.0

- **New**: `docker/operational_seed.sql` — data dummy transaksional untuk simulasi operasional 4 hari
- **New**: 8 kunjungan pasien (reg_periksa) dengan variasi poli, dokter, cara bayar, dan diagnosis
- **New**: 7 pemeriksaan rawat jalan (pemeriksaan_ralan) dengan SOAP lengkap
- **New**: 8 diagnosa pasien (diagnosa_pasien) — DM Tipe 2, Diare, Hernia, KB, Hipertensi, LBP (2), ISK
- **New**: 8 tindakan dokter rawat jalan (rawat_jl_dr) — konsultasi, pemeriksaan rutin, infus
- **New**: 7 resep obat (14 item) — Metformin, Amlodipine, Paracetamol, Cefixime, Ibuprofen, Captopril, dll
- **New**: 6 pemeriksaan lab (17 detail hasil) — Darah lengkap, GDS, Kolesterol, Asam Urat
- **New**: 1 rawat inap (kamar_inap) — Dewi Lestari di Kamar Melati 1
- **New**: 8 billing records (mlite_billing)
- **Fixed**: `pemeriksaan_ralan` — ditambahkan kolom `evaluasi` yang sebelumnya terlewat
- **New**: `mlite/docker/mlite_db_dump_with_seed.sql` — full database export (438KB, 8496 baris) — struktur + semua data
- **New**: `mlite/docker/seed_data.sql` — data dummy master tables (mandiri)
- **New**: `mlite/docker/operational_seed.sql` — data dummy operasional (mandiri)
- **Updated**: `TEST_REPORT.md` — test cases P-29 to P-38, skenario kunjungan, coverage table

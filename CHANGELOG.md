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

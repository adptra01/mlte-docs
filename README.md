# mLITE — SIM Kesehatan Aman, Ringan & Modular

**mLITE** adalah Sistem Informasi Rumah Sakit (SIMRS) / SIM Kesehatan open source, ringan, dan modular. Berjalan sebagai aplikasi web (PWA Ready) dengan arsitektur mobile-first (responsive).

- **Website**: https://mlite.id/
- **Repository**: https://github.com/basoro/mlite
- **Lisensi**: [GPL-3.0](./LICENSE)
- **Maintainer**: drg. F. Basoro
- **Versi Sumber**: 6.3.0 (Sabrina) + 32 commits — Commit: `20795136`
- **Tanggal Clone**: 21 Mei 2026

## Fitur Utama

SIM RS/Klinik/Puskesmas lengkap — rawat jalan, rawat inap, IGD, farmasi, keuangan, billing, rekam medis elektronik (SOAP), bridging BPJS, SATUSEHAT/FHIR, SNOMED-CT mapping (AI), APAM mobile, SQLite support, modular plugin system, API Backend, E-Signature, Workerman WebSocket.

## Quick Start

### Basic (tanpa optimasi)
```bash
git clone https://github.com/basoro/mlite.git && cd mlite/docker
cp .env.example .env
docker compose up -d
# http://localhost:8088 | admin/admin
```

### Optimized (full stack — Redis, MySQL tuning, gzip, opcache)
```bash
git clone https://github.com/basoro/mlite.git && cd mlite/docker
cp .env.test .env
docker compose -f compose.test.yaml up -d
# http://localhost:8088 | admin/admin
```

## Optimization Matrix

| Layer | Component | Basic | Optimized | Impact |
|-------|-----------|-------|-----------|--------|
| **Web Server** | Nginx gzip | Off | **On** (compression ~71%) | Bandwidth hemat |
| **Web Server** | Static caching | None | **30d expires** + immutable | Cache browser |
| **PHP** | OPcache | Default (8MB) | **128MB** + JIT tracing | Bytecode di RAM |
| **PHP** | APCu | ❌ | **64MB** user cache | Cache data aplikasi |
| **PHP** | PHP-FPM tuning | Default | **pm.max_children=15** | Concurrency |
| **PHP** | JIT buffer | 0 (disabled) | **256MB** (config, butuh rebuild) | CPU-bound speedup |
| **PHP** | CI_ENVIRONMENT | development | **production** | Debug toolbar mati |
| **PHP** | Composer autoload | Standard | **Optimized** (768 classes) | Class loading |
| **Session** | Session storage | File-based | **Redis 7.4** + TTL 7200s | In-memory |
| **Database** | Indexes | Minimal | **7 indexes** on 5 key tables | Query 10-100x |
| **Database** | InnoDB buffer | 128MB | **256MB** | Cache tabel/index |
| **Database** | tmp_table_size | 16MB | **64MB** | Temp query speed |
| **Database** | join_buffer | 256KB | **512KB** | JOIN performance |
| **Seed Data** | Master tables | ❌ | **25 pasien, 11 dokter, 28 kamar, dll** | Demo siap pakai |
| **Seed Data** | Operational | ❌ | **8 visits, lab, prescriptions, billing** | Skenario lengkap |

## Architecture (Optimized)

```
                                          ┌─────────────────────┐
  Browser ──▶ Nginx (gzip + cache 30d) ──▶│   PHP-FPM 8.1       │──▶ MySQL 8.0 (tuned)
               :80                         │   ├── OPcache 128MB │      ├── buffer_pool 256M
                                           │   ├── APCu 64MB     │      ├── 7 indexes
                                           │   ├── JIT tracing   │      ├── tmp_table 64M
                                           │   └── Redis session │      └── join_buffer 512K
                                           └─────────┬───────────┘
                                                     │
                                              ┌──────▼──────┐
                                              │  Redis 7.4  │
                                              │  (sessions) │
                                              └─────────────┘
```

## Dokumentasi Lengkap

| Dokumen | Isi |
|---------|-----|
| [INSTALL.md](./INSTALL.md) | Instalasi lokal dari nol (4 metode) |
| [RUNBOOK.md](./RUNBOOK.md) | Operasional harian Docker & Podman |
| [TEST_PLAN.md](./TEST_PLAN.md) | Skenario pengujian terstruktur |
| [TEST_REPORT.md](./TEST_REPORT.md) | Hasil eksekusi semua test case |
| [CHANGELOG.md](./CHANGELOG.md) | Perubahan dari versi asli |
| [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md) | Arsitektur sistem dan komponen |
| [docs/comparison-docker-podman.md](./docs/comparison-docker-podman.md) | Perbandingan Docker vs Podman |
| [docs/known-issues.md](./docs/known-issues.md) | Known issues dan workaround |

## Struktur Proyek

```
mlite-docker-podman-project/
├── README.md, INSTALL.md, RUNBOOK.md
├── TEST_PLAN.md, TEST_REPORT.md, CHANGELOG.md
├── Dockerfile, Containerfile, docker-compose.yml
├── .env.example, .dockerignore
├── LICENSE, NOTICE
├── docs/          # Dokumentasi detail
├── evidence/      # Log build, screenshot, hasil test
└── scripts/       # Script automation
```

## File Penting di `mlite/docker/`

| File | Kegunaan |
|------|----------|
| `docker-compose.yaml` | Basic compose (nginx + php + mysql) |
| `compose.test.yaml` | Optimized compose (+redis, mysql tuning, seed data) |
| `.env` | Environment variables untuk basic compose |
| `.env.test` | Environment variables untuk optimized compose |
| `php.quick.Dockerfile` | PHP 8.1 dengan APCu + Redis + opcache + FPM tuning |
| `php/redis-session.ini` | Redis session handler config |
| `nginx/default.conf` | Nginx config dengan gzip + static caching |
| `mysql/my.cnf` | MySQL InnoDB tuning (buffer pool 256M) |
| `seed_data.sql` | Master tables dummy data (635 rows) |
| `operational_seed.sql` | Transactional data (194 rows) |
| `mlite_db_dump_with_seed.sql` | Full DB dump with seed data (439 KB) |

## Persyaratan Sistem

| Komponen | Kebutuhan |
|----------|-----------|
| Web Server | Apache 2.2+ (`mod_rewrite`) atau Nginx |
| PHP | 7.4 – 8.3+ |
| Database | MySQL 5.7+ / MariaDB 10+ / SQLite |
| Redis (opsional) | 7.x (untuk session storage) |
| Composer | Wajib untuk dependensi PHP |
| Container | Docker 20.10+ atau Podman 4.0+ |

## Lisensi

**GNU General Public License v3.0** — dikembangkan oleh **drg. F. Basoro** dan kontributor.

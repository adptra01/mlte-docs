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

### Docker
```bash
git clone https://github.com/basoro/mlite.git && cd mlite
docker compose up -d
# http://localhost:8088 | admin/admin
```

### Podman
```bash
git clone https://github.com/basoro/mlite.git && cd mlite
podman-compose up -d
# http://localhost:8088 | admin/admin
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

## Persyaratan Sistem

| Komponen | Kebutuhan |
|----------|-----------|
| Web Server | Apache 2.2+ (`mod_rewrite`) atau Nginx |
| PHP | 7.4 – 8.3+ |
| Database | MySQL 5.7+ / MariaDB 10+ / SQLite |
| Composer | Wajib untuk dependensi PHP |
| Container | Docker 20.10+ atau Podman 4.0+ |

## Lisensi

**GNU General Public License v3.0** — dikembangkan oleh **drg. F. Basoro** dan kontributor.

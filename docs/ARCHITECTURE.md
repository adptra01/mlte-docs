# ARCHITECTURE — Arsitektur Sistem mLITE

## Gambaran Umum

mLITE adalah aplikasi monolitik PHP dengan **Independent Framework** — framework custom yang ringan dan modular. Arsitektur mengikuti pola **Model-less Controller**, di mana logika bisnis dan view menyatu dalam file plugin.

### Basic Architecture (tanpa optimasi)
```
Browser ──▶ Nginx ──▶ PHP-FPM ──▶ MySQL/SQLite
              :80        │            (Database)
                         │
                  ┌──────┴──────┐
                  │   Systems   │
                  │   Site.php  │ (Router)
                  ├─────────────┤
                  │  plugins/   │ (Modul)
                  │  themes/    │ (Tampilan)
                  └─────────────┘
```

### Optimized Architecture (full stack)
```
                                     ┌────────────────────────────┐
Browser ──▶ Nginx (gzip + cache) ──▶│      PHP-FPM 8.1           │──▶ MySQL 8.0 (tuned)
               :80                   │  ┌──────────────────────┐  │      ├── buffer_pool=256M
  ▲                                 │  │    OPcache 128MB     │  │      ├── tmp_table=64M
  │ 30d cache (CSS/JS/img)          │  │  + JIT (tracing)     │  │      ├── join_buffer=512K
  │ gzip (71% compression)          │  ├──────────────────────┤  │      ├── sort_buffer=512K
  │ Vary: Accept-Encoding           │  │   APCu 64MB cache    │  │      └── 7 custom indexes
  └─────────────────────────────────│  ├──────────────────────┤  │
                                    │  │ Session: Redis 7.4   │──┤──▶ Redis 7.4
                                    │  │ TTL: 7200s (2 jam)   │  │      (AOF persistence)
                                    │  └──────────────────────┘  │
                                    └────────────────────────────┘
```

## Entry Point

**`index.php`** — Semua request masuk melalui file ini (via URL rewriting).

Flow:
```
Request → .htaccess/Nginx rewrite → index.php
  ├── define BASE_DIR
  ├── require config.php (parse .env, constants)
  ├── require Autoloader.php
  └── new Systems\Site()
        ├── Parse URL → /module/action/params
        ├── PHP session → Redis (if configured)
        ├── Auth check → login form or proceed
        ├── Load theme (header, sidebar, footer)
        ├── Load plugin/module
        │     ├── Execute module logic
        │     ├── Query database (MySQL with indexes)
        │     └── Generate output
        └── Render HTML → Nginx gzip → Browser
```

## Komponen Utama

| Komponen | Lokasi | Fungsi |
|----------|--------|--------|
| Entry Point | `index.php` | Router utama, load config & autoloader |
| Config | `config.php` | Parse .env, define konstanta |
| Core Router | `systems/lib/Site.php` | Route request ke plugin yang sesuai |
| Database | `systems/lib/Database.php` | Abstraksi PDO (MySQL/SQLite) |
| Autoloader | `systems/lib/Autoloader.php` | Class autoloading |
| Plugins | `plugins/` | Modul modular (fitur aplikasi) |
| Themes | `themes/` | Template tampilan (Bootstrap) |
| Admin | `admin/` | Panel administrasi terpisah |
| Assets | `assets/` | CSS, JS, gambar global |

## Plugin System

Setiap plugin adalah modul mandiri:

```
plugins/<nama>/
├── <nama>.php       # Main plugin file
├── setting.php      # Pengaturan plugin
├── README.md        # Dokumentasi plugin
└── ...              # View, helper, dll
```

**Plugin inti**: dashboard, master, pasien, rawat_jalan, rawat_inap, igd, farmasi, kasir, kepegawaian, keuangan, lab, radiologi, bpjs, satu_sehat, apotek_online, e_signature

## Database

| Driver | File | Production Ready |
|--------|------|-----------------|
| MySQL | `mlite_db.sql` (dump) | ✅ |
| SQLite | Auto-created di `systems/data/mlite.sdb` | ❌ (development) |

### MySQL Indexes (Optimized)

| Tabel | Index Baru | Untuk Query |
|-------|-----------|-------------|
| `reg_periksa` | `(tgl_registrasi)` | Laporan harian/bulanan kunjungan |
| `reg_periksa` | `(no_rkm_medis, tgl_registrasi)` | Riwayat kunjungan pasien |
| `mlite_billing` | `(no_rawat)` | Lookup billing per kunjungan |
| `mlite_billing` | `(tgl_billing)` | Laporan keuangan harian |
| `pemeriksaan_ralan` | `(tgl_perawatan)` | Range tanggal pemeriksaan |
| `pasien` | `(tgl_daftar)` | Laporan pasien baru |
| `kamar_inap` | `(tgl_masuk)` | Laporan rawat inap |

### MySQL Tuning

| Parameter | Default | Optimized |
|-----------|---------|-----------|
| `innodb_buffer_pool_size` | 128 MB | **256 MB** |
| `tmp_table_size` | 16 MB | **64 MB** |
| `join_buffer_size` | 256 KB | **512 KB** |
| `sort_buffer_size` | 256 KB | **512 KB** |
| `innodb_log_file_size` | 48 MB | **64 MB** |
| `innodb_flush_log_at_trx_commit` | 1 | **2** |

## Caching Layer (Optimized)

| Layer | Teknologi | Konfigurasi | Manfaat |
|-------|-----------|-------------|---------|
| **Session** | Redis 7.4 | `session.save_handler=redis` | Session in-memory, survive restart |
| **Bytecode** | OPcache | 128MB, 10000 files, JIT tracing | Tanpa compile ulang script |
| **User cache** | APCu | 64MB, TTL 7200s | Cache data aplikasi |
| **HTTP** | Nginx gzip | level 5, text/css/js/json/svg | Bandwidth ~71% lebih kecil |
| **HTTP** | Nginx expires | 30d, immutable, Cache-Control | Static assets di-cache browser |
| **Framework** | CI_ENV | production | Debug toolbar mati |

## Session Flow (with Redis)

```
User Login ──▶ PHP session_start()
                  │
                  ▼
           Redis (tcp://redis:6379)
           ├── Key: mlite_session_{hash}
           ├── Value: user data (serialized)
           ├── TTL: 7200s
           └── AOF: persisted to disk
                  │
                  ▼
           Subsequent requests
           ├── Cookie: mlite={hash}
           └── Redis lookup → auth success
```

## Integrasi Eksternal

| Layanan | Protokol | Fungsi |
|---------|----------|--------|
| BPJS Kesehatan | REST/SOAP | Kepesertaan, SEP, klaim |
| SATUSEHAT | FHIR R4 | Rekam medis nasional |
| OpenRouter AI | REST | SNOMED-CT mapping |
| iDRG | REST | INA-CBGs claim |

## Keamanan

- Session-based authentication (Redis or file)
- JWT untuk API (secret: `config.php`)
- Role-based access (admin, dokter, perawat, dll)
- Prepared statements (PDO) untuk SQL injection prevention
- File upload validation
- Admin panel terpisah dengan akses terbatas

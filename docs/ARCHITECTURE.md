# ARCHITECTURE — Arsitektur Sistem mLITE

## Gambaran Umum

mLITE adalah aplikasi monolitik PHP dengan **Independent Framework** — framework custom yang ringan dan modular. Arsitektur mengikuti pola **Model-less Controller**, di mana logika bisnis dan view menyatu dalam file plugin.

```
Browser ──▶ Web Server ──▶ PHP-FPM ──▶ MySQL/SQLite
              (Nginx)     (index.php)    (Database)
                             │
                      ┌──────┴──────┐
                      │   Systems   │
                      │   Site.php  │ (Router)
                      ├─────────────┤
                      │  plugins/   │ (Modul)
                      │  themes/    │ (Tampilan)
                      └─────────────┘
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
        ├── Auth check → login form or proceed
        ├── Load theme (header, sidebar, footer)
        ├── Load plugin/module
        │     ├── Execute module logic
        │     ├── Query database
        │     └── Generate output
        └── Render HTML
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

## Integrasi Eksternal

| Layanan | Protokol | Fungsi |
|---------|----------|--------|
| BPJS Kesehatan | REST/SOAP | Kepesertaan, SEP, klaim |
| SATUSEHAT | FHIR R4 | Rekam medis nasional |
| OpenRouter AI | REST | SNOMED-CT mapping |
| iDRG | REST | INA-CBGs claim |

## Keamanan

- Session-based authentication
- JWT untuk API (secret: `config.php`)
- Role-based access (admin, dokter, perawat, dll)
- Prepared statements (PDO) untuk SQL injection prevention
- File upload validation
- Admin panel terpisah dengan akses terbatas

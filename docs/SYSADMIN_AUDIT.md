# System Administration Audit — mLITE SIMRS

> **Status**: Completed | **Date**: 22 May 2026 | **Fase**: A (Audit Sistem & Inventarisir Status Quo)

---

## 1. Identitas Sistem

| Atribut | Nilai |
|---------|-------|
| **Nama Aplikasi** | mLITE — SIM Kesehatan Aman, Ringan & Modular |
| **Versi** | 6.3.0 (Sabrina) + 32 commits — Commit `20795136` |
| **Lisensi** | GPL-3.0 |
| **Maintainer** | drg. F. Basoro (`dentix.id@gmail.com`) |
| **Framework** | Custom Independent Framework |
| **Repository** | [github.com/basoro/mlite](https://github.com/basoro/mlite) |
| **Website** | [mlite.id](https://mlite.id) |
| **Tanggal Clone** | 21 May 2026 |

---

## 2. Infrastruktur

### Container Stack (Docker/Podman)

```
Host:8088 ──▶ Nginx:1.31.0 (alpine) ──▶ PHP-FPM:8.1.34 (alpine) ──▶ MySQL:8.0.46
                                              │
                                         Redis:7.4.9 (sessions)
```

| Service | Image | Base | Status |
|---------|-------|------|--------|
| **nginx** | `nginx:alpine` | Alpine Linux | ✅ Running |
| **php** | `mlite-php:local` | `php:8.1-fpm-alpine` | ✅ Running |
| **mysql** | `mysql:8.0` | Oracle Linux | ✅ Running |
| **redis** | `redis:7-alpine` | Alpine Linux | ✅ Running |

### Runtime

| Komponen | Detail |
|----------|--------|
| **Host OS** | Windows (Podman 5.7.1, docker-compose.exe external) |
| **Container Runtime** | Podman 5.7.1 (with docker-compose.exe provider) |
| **Orchestration** | docker-compose v2 via `compose.test.yaml` |
| **Networking** | bridge (internal network) |
| **Storage Driver** | overlay2 (via Podman) |

---

## 3. PHP Configuration

### Version & Runtime
```
PHP 8.1.34 (cli) (built: Dec 19 2025 23:43:03) (NTS)
Zend Engine v4.1.34
with Zend OPcache v8.1.34
```

### Extensions (39 modules)
```
Core modules: Core, ctype, curl, date, dom, fileinfo, filter, ftp, gd, hash, iconv,
              json, libxml, mbstring, mysqli, mysqlnd, openssl, pcre, PDO, pdo_mysql,
              pdo_sqlite, Phar, posix, readline, Reflection, session, SimpleXML, sodium,
              SPL, sqlite3, standard, tokenizer, xml, xmlreader, xmlwriter, zip, zlib

Optimization: apcu, redis, Zend OPcache
```

### Optimization Config

| Parameter | Value | Notes |
|-----------|-------|-------|
| **OPcache** | `memory_consumption=128M` | Bytecode cache |
| | `max_accelerated_files=10000` | |
| | `revalidate_freq=2` | Revalidate every 2s |
| | `jit=tracing` | JIT compilation |
| | `jit_buffer_size=0` | ⚠️ Not allocated! Needs config |
| **APCu** | `shm_size=64M` | User cache |
| | `ttl=7200` | 2 hour TTL |
| **PHP-FPM** | `pm.max_children=15` | Process management |
| | `pm.start_servers=4` | |
| | `pm.max_requests=500` | |
| **Session** | `save_handler=redis` | In-memory sessions |
| | `save_path=tcp://redis:6379` | With auth + prefix |
| | `gc_maxlifetime=7200` | 2 hour session lifetime |
| **Environment** | `CI_ENVIRONMENT=production` | Debug toolbar disabled |

### Resource Limits

| Parameter | Value | Recommended |
|-----------|-------|-------------|
| `memory_limit` | 128M | 256M (production) |
| `max_execution_time` | 0 (unlimited) | 300 (CLI), 60 (FPM) |
| `post_max_size` | 8M | **20M** (current too small) |
| `upload_max_filesize` | 2M | **20M** (current too small) |
| `max_input_time` | -1 | -1 is fine |

---

## 4. Database (MySQL 8.0.46)

### Overview
| Metrik | Nilai |
|--------|-------|
| Server Version | MySQL 8.0.46 (Community) |
| Total Tables | 234 |
| Database Size | 12.06 MB |
| Storage Engine | InnoDB (majority), MyISAM (minor) |
| Total Indexes | ~150+ (including 7 custom) |

### Tuning Parameters

| Parameter | Default | Current | Impact |
|-----------|---------|---------|--------|
| `innodb_buffer_pool_size` | 128M | **256M** | Cache tabel/index di RAM |
| `tmp_table_size` | 16M | **64M** | Temp query lebih besar |
| `max_heap_table_size` | 16M | **64M** | Memory table size |
| `join_buffer_size` | 256K | **512K** | JOIN performance |
| `sort_buffer_size` | 256K | **512K** | Sorting performance |
| `innodb_log_file_size` | 48M | **64M** | Write-heavy workloads |
| `innodb_flush_log_at_trx_commit` | 1 | **2** | Faster (slightly less durable) |
| `max_connections` | 151 | **50** | Adequate for current scale |

### Custom Indexes Added

| Table | Index | Purpose |
|-------|-------|---------|
| `reg_periksa` | `(tgl_registrasi)` | Laporan harian kunjungan |
| `reg_periksa` | `(no_rkm_medis, tgl_registrasi)` | Riwayat pasien |
| `mlite_billing` | `(no_rawat)` | ⭐ Lookup billing per kunjungan |
| `mlite_billing` | `(tgl_billing)` | Laporan keuangan harian |
| `pemeriksaan_ralan` | `(tgl_perawatan)` | Range tanggal pemeriksaan |
| `pasien` | `(tgl_daftar)` | Laporan pasien baru |
| `kamar_inap` | `(tgl_masuk)` | Laporan rawat inap |

### Seed Data

**Master Data** (file: `seed_data.sql`, 635 baris):
- 25 pasien, 11 dokter, 22 pegawai, 22 petugas
- 22 databarang (obat), 15 poliklinik, 28 kamar, 30 penyakit
- 10 propinsi, 22 kecamatan, 19 kelurahan
- Tarif, rekening, akun bank, dll.

**Operational Data** (file: `operational_seed.sql`, 194 baris):
- 8 kunjungan (4 hari, 6 poli, 7 dokter, 4 cara bayar)
- 7 pemeriksaan, 8 diagnosa, 8 tindakan medis
- 7 resep (14 item obat), 6 laboratorium (17 detail)
- 1 rawat inap, 8 billing

---

## 5. Redis (Session Storage)

| Parameter | Value |
|-----------|-------|
| **Version** | 7.4.9 |
| **Image** | `redis:7-alpine` |
| **Extension** | phpredis 6.3.0 |
| **Handler** | `session.save_handler = redis` |
| **Connection** | `tcp://redis:6379?auth=mlite_redis_pass&prefix=mlite_session_&timeout=2` |
| **TTL** | 7200s (2 jam) |
| **Persistence** | AOF (Append-Only File) — `redis_data` volume |
| **Auth** | Password: `mlite_redis_pass` |

---

## 6. Nginx Web Server

| Parameter | Value |
|-----------|-------|
| **Version** | 1.31.0 |
| **Image** | `nginx:alpine` |
| **Listen** | 0.0.0.0:80 |
| **Root** | `/var/www/html` |
| **Client Max Body** | 100M |

### Gzip Compression
| Parameter | Value |
|-----------|-------|
| Status | On |
| Level | 5 |
| Min Length | 256 bytes |
| Types | text/plain, text/css, text/javascript, application/javascript, application/json, application/xml, image/svg+xml, font/ttf, font/otf |
| Ratio | ~71% (5790 → 1674 bytes) |

### Static Caching
```
location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff2?|ttf|svg|eot)$ {
    expires 30d;
    add_header Cache-Control "public, immutable";
}
```

---

## 7. Plugin Inventory (54 Registered)

### Klasifikasi Awal (detail di Fase C)

| Kategori | Jumlah | Daftar |
|----------|--------|--------|
| **Core Mandatory** | 11 | settings, dashboard, master, pasien, rawat_jalan, rawat_inap, igd, farmasi, kasir_rawat_jalan, kasir_rawat_inap, users, modules |
| **Clinical** | 8 | dokter_ralan, dokter_ranap, dokter_igd, laboratorium, radiologi, operasi, apotek_ralan, apotek_ranap |
| **BPJS/Integration** | 7 | vclaim, bridging_hfis, satu_sehat, pcare, bpjs_emr, jkn_mobile, jkn_mobile_fktp |
| **Finance** | 4 | keuangan, kepegawaian, jasa_medis, penjualan |
| **Reporting** | 3 | laporan, manajemen, profil |
| **Communication** | 4 | wagateway, api, icare, mlite_api_key |
| **Specialized** | 15 | anjungan, orthanc, mini_pacs, oral_diagnostic, esignature, sertisign, presensi, surat, utd, vedika, veronisa, afm, mlite_logs, inventaris, crud_generator, website |

### Plugin dengan Disk Usage Terbesar

| Plugin | Size | Kategori | Catatan |
|--------|------|----------|---------|
| `mini_pacs` | 20.4 MB | Specialized | DICOM image viewer — asset berat |
| `anjungan` | 6.0 MB | Specialized | Kiosk/queue display |
| `orthanc` | 3.9 MB | Specialized | PACS connector |
| `mlite_api_key` | 1.8 MB | Communication | API key management |
| `master` | 1.3 MB | Core | Master data management |
| `website` | 1.1 MB | Specialized | Public website/PWA |
| `vedika` | 972 KB | BPJS | BPJS VEDIKA integration |
| `vclaim` | 916 KB | BPJS | BPJS VClaim integration |

---

## 8. Dependencies Eksternal

### Composer Packages (8)
| Package | Version | Purpose |
|---------|---------|---------|
| `nullpunkt/lz-string-php` | ^1.3 | LZ-String compression |
| `phpseclib/phpseclib` | ~3.0.36 | Secure communications |
| `phpmailer/phpmailer` | ^6.9.1 | Email sending |
| `mpdf/mpdf` | ^8.2 | PDF generation (reports, prescriptions) |
| `mpdf/qrcode` | ^1.2 | QR code generation |
| `workerman/workerman` | ^4.0 | WebSocket server |
| `halaxa/json-machine` | ^1.2 | Large JSON parsing |
| `composer` | latest | Dependency manager |

### External API Integrations
| Integration | Protocol | Plugin | Purpose |
|-------------|----------|--------|---------|
| BPJS Kesehatan | REST/SOAP | vclaim, bridging_hfis, pcare | SEP, klaim, referensi, PCare |
| SATUSEHAT | FHIR R4 | satu_sehat | Rekam medis nasional |
| OpenRouter AI | REST | satu_sehat | SNOMED-CT mapping |
| INA-CBGs / iDRG | REST | vedika | Klaim casemix |
| Orthanc PACS | DICOM/REST | orthanc | Medical image storage |
| Sertisign | REST | sertisign | Tanda tangan elektronik |
| WhatsApp Gateway | HTTP | wagateway | Notifikasi pasien |
| JKN Mobile | REST | jkn_mobile, jkn_mobile_fktp | Mobile JKN integration |

---

## 9. User Roles & Permissions

### Database Users
| User | Password | Access |
|------|----------|--------|
| `root` | `rootpassword123` | MySQL root (full access) |
| `mlite` | `mlite` | Database user (schema: `mlite_db`) |
| `admin` | `admin` | Aplikasi (superadmin) |

### Aplikasi User Roles (from `mlite_users`)
| Role | Deskripsi |
|------|-----------|
| admin | Superadmin — full access to all modules |
| *(others)* | Roles defined by module-level permissions in `mlite_crud_permissions` |

Note: Detailed role mapping requires further investigation of `mlite_users` table and `mlite_crud_permissions`.

### Permission System
- Module-level: each module has read/create/update/delete permissions
- User-level: each user can be assigned to specific modules
- API: JWT-based authentication for API access
- Session: PHP session stored in Redis (previously file-based)

---

## 10. Known Issues & Warnings

| Issue | Severity | Status |
|-------|----------|--------|
| PHP JIT `buffer_size=0` — JIT enabled but no buffer allocated | LOW | Config exists but buffer not set |
| `post_max_size=8M` — too small for uploads | MEDIUM | Change to 20M |
| `upload_max_filesize=2M` — too small for images/documents | MEDIUM | Change to 20M |
| MySQL config file `world-writable` — ignored by MySQL | LOW | Fixed: chmod 644 |
| Docker compose warning: REDIS_PASSWORD not set | LOW | Env file location mismatch |
| SQLite mode broken — MySQL dump not compatible | MEDIUM | SQLite driver limitation |
| Composer install on every startup — slow first request | MEDIUM | Build pre-composed image |
| PHP image large (~650MB) | LOW | Multi-stage build planned |

---

## 11. Infrastruktur Resource Usage

| Resource | Usage | Notes |
|----------|-------|-------|
| **Database size** | 12.06 MB | 234 tables, seed data loaded |
| **Largest plugin** | 20.4 MB (mini_pacs) | DICOM assets |
| **Total PHP image** | ~650 MB | Build dependencies included |
| **MySQL config** | 256 MB buffer pool | Custom tuned |
| **Redis** | Minimal (< 1 MB) | Session data only (demo scale) |

---

## 12. Next Steps (Fase C → E)

Berdasarkan audit ini, langkah selanjutnya:

1. ~~Fase B — Analisis Operasional: Dokumentasi workflow nyata, skala, statistik penggunaan~~ ✅
2. ~~Fase C — Klasifikasi Plugin: Evaluasi setiap plugin (dampak performa, frekuensi, rekomendasi)~~ ✅
3. **Fase D** — Performance & Bottleneck: Profiling query, session, caching, UX weight
4. **Fase E** — UI/UX Analysis: Workflow mapping per klik, usability issues
5. **Fase F** — Arsitektur & Security Review
6. **Fase G** — Scalability Planning
7. **Fase H** — Roadmap & Recommendations
8. **Fase I** — Final Documentation

---

---

## 13. Fase B -- Analisis Operasional

### 13.1 User Inventory

| ID | Username | Fullname | Role |
|----|----------|----------|------|
| 1 | admin | Administrator | admin |
| 2 | DR001 | dr. Ataaka Muhammad | admin |
| 3 | DR002 | dr. Siti Rahmawati, Sp.PD | dokter |
| 4 | DR003 | dr. Budi Santoso, Sp.A | dokter |
| 5 | AD001 | Sari Utami, S.E. | user |
| 6 | FR001 | Apt. Dwi Prasetyo, S.Farm., M.Farm | user |

**Komposisi**: 2 admin, 2 dokter, 2 user (staf)

### 13.2 Module Sequence (Load Order)

Modul dimuat berdasarkan urutan sequence:
dashboard(0) -> master(1) -> pasien(2) -> rawat_jalan(3) -> kasir_rawat_jalan(4) -> kepegawaian(5) -> farmasi(6) -> modules(7) -> users(8) -> settings(9) -> wagateway(10) -> apotek_ralan(11) -> ... -> website(54)

### 13.3 Operational Data Volume

| Domain | Count | Keterangan |
|--------|-------|------------|
| Kunjungan (reg_periksa) | 8 | 4 hari (18-21 May 2026) |
| Pasien (pasien) | 25 | Data master + sample |
| Pemeriksaan Ralan | 7 | 7 dari 8 kunjungan diperiksa |
| Diagnosa | 8 | Multiple diagnosa per pasien |
| Resep (resep_obat) | 7 | 14 item dari 22 obat |
| Laboratorium | 6 periksa, 17 detail | 2 jenis tes |
| Rawat Inap | 1 | 0/28 kamar terisi |
| Billing | 8 | Total Rp 910.000 -- semua belum dibayar |
| Trial log | 1 | 1 login attempt |
| Settings (mlite_settings) | 214 | Konfigurasi lintas modul |
| Jurnal | 15 header, 87 detail | Transaksi keuangan |

### 13.4 Visit Distribution

| Poli | Kunjungan |
|------|-----------|
| UMU (Umum) | 3 |
| ANAK | 1 |
| BEDAH | 1 |
| IGDK | 1 |
| OBGYN | 1 |
| SARAF | 1 |

| Cara Bayar | Kunjungan |
|------------|-----------|
| BPJS | 4 |
| UMUM | 2 |
| JKN | 1 |
| PERUSAHAAN | 1 |

### 13.5 Status Kunjungan

| Status | Jumlah |
|--------|--------|
| Sudah | 7 |
| Dirawat | 1 |

### 13.6 Empty Tables Analysis

**154 dari 234 tables (66%) kosong total**. Domain yang belum terisi:
- BPJS Integration: semua tabel bridging kosong (SEP, rujukan, kontrol, dll.)
- SATUSEHAT: mapping, response, lokasi kosong
- Radiologi: semua tabel kosong
- Operasi: booking, laporan, dll. kosong
- Presensi & Kepegawaian: jadwal, presensi kosong
- UTD (Donor Darah): semua tabel kosong
- Penilaian Medis: IGD, Ralan, Ranap, Keperawatan kosong
- Farmasi Lanjutan: pemesanan, penerimaan, racikan kosong
- Mini PACS: semua tabel kosong (belum ada gambar)
- Terisi: Master data (pasien, dokter, barang, poli), kunjungan sample, billing, resep

### 13.7 System Maturity Assessment

| Aspek | Maturity | Notes |
|-------|----------|-------|
| Data Volume | Demo | Seed + sample operasional |
| User Base | Minimal | 6 users, single-site |
| Workflow Coverage | Partial | Ralan flow works, Ranap minimal, IGD partial |
| Integration Data | Empty | BPJS, SATUSEHAT, PACS kosong |
| Clinical Records | Partial | Pemeriksaan + diagnosa + resep ada |
| Financial | Demo | Billing record lengkap tapi unpaid |
| Configuration | Complete | 214 settings configured |

### 13.8 Workflow Chain (Rawat Jalan Complete)

```
Registrasi (reg_periksa)
    |
Pemeriksaan (pemeriksaan_ralan)
    |
Diagnosa (diagnosa_pasien) --- Tindakan Medis
    |                                   |
Resep (resep_obat) -------- Billing (mlite_billing)
    |
Penyerahan Obat (resep_obat.tgl_penyerahan)
```

### 13.9 Operational Gaps

1. Semua billing unpaid -- tidak ada workflow pembayaran dalam sample
2. Rawat Inap hanya 1 -- tidak cukup untuk analisis pola
3. IGD hanya 1 kunjungan -- tidak ada triase
4. Tidak ada sampel BPJS -- SEP, rujukan, kontrol kosong
5. Peresepan ada tapi detail racikan kosong
6. Farmasi stok opname kosong
7. Radiologi dan laboratorium permintaan kosong (hanya hasil langsung)

---

---

## 14. Fase C -- Klasifikasi & Evaluasi Plugin

### 14.1 Klasifikasi

**E (Essential)**: Tidak bisa dinonaktifkan -- core system
**O (Operational)**: Dibutuhkan untuk workflow klinis/bisnis
**I (Integration)**: Konektor eksternal, tergantung deployment
**S (Specialized)**: Domain-specific, opsional
**R (Rarely Used)**: Niche, jarang dipakai

### 14.2 Plugin by Class

#### Essential (10)

| Plugin | Size | PHP | JS | Sequence |
|--------|------|-----|-----|----------|
| dashboard | 164K | 3 | 2 | 0 |
| master | 1.3M | 52 | 49 | 1 |
| pasien | 436K | 2 | 1 | 2 |
| rawat_jalan | 672K | 2 | 1 | 3 |
| kasir_rawat_jalan | 244K | 2 | 1 | 4 |
| kepegawaian | 60K | 2 | 1 | 5 |
| farmasi | 168K | 2 | 4 | 6 |
| modules | 40K | 2 | 0 | 7 |
| users | 88K | 3 | 1 | 8 |
| settings | 144K | 6 | 0 | 9 |

#### Operational -- Clinical (8)

| Plugin | Size | PHP | JS | Keterangan |
|--------|------|-----|-----|------------|
| igd | 552K | 2 | 1 | IGD registration + triase |
| dokter_igd | 548K | 2 | 1 | Dokter IGD workspace |
| rawat_inap | 552K | 2 | 1 | Manajemen rawat inap |
| dokter_ranap | 372K | 2 | 1 | Dokter rawat inap workspace |
| dokter_ralan | 632K | 2 | 1 | Dokter rawat jalan workspace |
| apotek_ralan | 184K | 2 | 1 | Apotek rawat jalan |
| apotek_ranap | 188K | 2 | 1 | Apotek rawat inap |
| operasi | 152K | 2 | 1 | Penjadwalan operasi |

#### Operational -- Diagnostic (2)

| Plugin | Size | PHP | JS |
|--------|------|-----|-----|
| laboratorium | 196K | 2 | 1 |
| radiologi | 196K | 2 | 1 |

#### Operational -- Financial (4)

| Plugin | Size | PHP | JS |
|--------|------|-----|-----|
| kasir_rawat_inap | 212K | 2 | 1 |
| keuangan | 192K | 3 | 1 |
| jasa_medis | 52K | 2 | 1 |
| penjualan | 92K | 2 | 0 |

#### Operational -- Reporting (3)

| Plugin | Size | PHP | JS |
|--------|------|-----|-----|
| laporan | 100K | 2 | 1 |
| manajemen | 296K | 2 | 0 |
| profil | 96K | 2 | 2 |

#### Integration -- BPJS & Government (8)

| Plugin | Size | PHP | JS | Target |
|--------|------|-----|-----|--------|
| vclaim | 916K | 2 | 0 | BPJS VClaim API |
| bridging_hfis | 56K | 2 | 1 | BPJS HFIS |
| bpjs_emr | 268K | 2 | 0 | BPJS EMR |
| jkn_mobile | 548K | 3 | 2 | JKN Mobile |
| jkn_mobile_fktp | 248K | 3 | 3 | JKN Mobile FKTP |
| pcare | 496K | 2 | 0 | BPJS PCare |
| vedika | 972K | 3 | 2 | BPJS VEDIKA/klaim |
| satu_sehat | 552K | 19 | 0 | SATUSEHAT FHIR R4 |

#### Integration -- Communication (4)

| Plugin | Size | PHP | JS |
|--------|------|-----|-----|
| wagateway | 84K | 2 | 0 |
| api | 144K | 3 | 1 |
| mlite_api_key | 1.8M | 2 | 4 |
| icare | 20K | 2 | 0 |

#### Specialized (14)

| Plugin | Size | PHP | JS | Notes |
|--------|------|-----|-----|-------|
| mini_pacs | 20.4M | 6 | 9 | DICOM viewer |
| anjungan | 6.0M | 3 | 9 | Kiosk/antrian |
| orthanc | 3.9M | 2 | 8 | PACS connector |
| esignature | 56K | 3 | 2 | Digital signature |
| sertisign | 52K | 3 | 0 | Sertisign API |
| presensi | 256K | 2 | 1 | Absensi/fingerprint |
| surat | 96K | 2 | 0 | Surat-menyurat |
| utd | 92K | 2 | 1 | Unit transfusi darah |
| oral_diagnostic | 392K | 2 | 1 | Diagnostik gigi |
| afm | 36K | 3 | 1 | Biaya tambahan |
| veronisa | 472K | 3 | 2 | INA-CBGs |
| inventaris | 120K | 2 | 1 | Asset inventory |
| crud_generator | 120K | 2 | 1 | Code generator |
| mlite_logs | 48K | 2 | 1 | System logs |

#### Website (1)

| Plugin | Size | PHP | JS |
|--------|------|-----|-----|
| website | 1.1M | 3 | 4 |

### 14.3 Summary

| Class | Count | Total Size | % of Total |
|-------|-------|------------|------------|
| Essential | 10 | 3.4 MB | 7.2% |
| Operational | 17 | 5.4 MB | 11.5% |
| Integration | 12 | 5.8 MB | 12.3% |
| Specialized | 15 | 33.9 MB | 72.1% |
| **Total** | **54** | **47.0 MB** | **100%** |

### 14.4 Key Observations

1. **master plugin** (52 PHP, 49 JS, 1.3 MB) adalah plugin terbesar secara kode -- hub utama untuk CRUD semua data master
2. **mini_pacs** (20.4 MB) menyumbang 43% dari total ukuran plugin -- DICOM viewer assets
3. **54 plugins, hanya 10 Essential** -- 44 plugins bisa dinonaktifkan sesuai kebutuhan deployment
4. **satu_sehat** memiliki 19 PHP files vs rata-rata 2-3 -- integrasi FHIR paling kompleks
5. **Semua plugin tanpa SQL migration** -- skema dibuat via PHP pada saat load modul

### 14.5 Recommendations

- mini_pacs: Pertimbangkan lazy-load DICOM viewer assets hanya saat dibutuhkan
- anjungan: Hanya aktifkan untuk faskes dengan kiosk/queue display publik
- BPJS plugins: Hanya relevan untuk faskes yang melayani BPJS
- satusehat: Wajib untuk faskes yang sudah wajib SATUSEHAT (2024+)
- Tidak ada SQL migration files -- pertimbangkan migrasi ke migration-based schema di masa depan

---

## 15. Fase D -- Performance & Bottleneck Analysis

### 15.1 Resource Usage (at idle)

| Container | RAM | % Host | PIDs |
|-----------|-----|--------|------|
| MySQL 8.0 | 437 MB | 5.31% | 38 |
| PHP 8.1-FPM | 47 MB | 0.58% | 5 |
| Nginx 1.31 | 13 MB | 0.16% | 13 |
| Redis 7.4 | 5.5 MB | 0.07% | 6 |
| **Total** | **~503 MB** | **6.12%** | **62** |

### 15.2 Page Load Timing (internal, cold OPcache)

| Page | Load Time | Notes |
|------|-----------|-------|
| Login (/) | 1591 ms | Cold cache (first load) |
| Dashboard | 531 ms | Normal load |
| Master Data | 497 ms | Normal load |
| Pasien | 541 ms | Normal load |
| Rawat Jalan | 768 ms | Normal load |

### 15.3 OPcache Status

| Parameter | Value | Status |
|-----------|-------|--------|
| Enabled | On (FPM only) | Normal |
| Memory | 128 MB | Adequate |
| Max files | 10000 | Adequate |
| JIT | tracing mode | Enabled but ZERO buffer |
| jit_buffer_size | 0 | NOT ALLOCATED -- JIT inactive |
| interned_strings_buffer | 8 MB | Default, can increase |
| revalidate_freq | 2 s | Good |
| validate_timestamps | On | Fine for dev, Off for prod |
| preload | Not configured | Not used |

### 15.4 APCu Status

| Parameter | Value |
|-----------|-------|
| Enabled | On (FPM only) |
| Memory | 64 MB |
| Cached entries | 0 (app does not use APCu) |
| **Reality** | 64 MB allocated but ZERO utilization |

### 15.5 Redis Session Status

| Parameter | Value |
|-----------|-------|
| Handler | redis (correct) |
| Connected | Yes (2 connections) |
| Current keys | 2 sessions |
| Keyspace hits | 0 (idle) |
| Memory | 5.5 MB |
| **Status** | Functional but idle (demo) |

### 15.6 MySQL Performance

| Metric | Value |
|--------|-------|
| Queries since startup | 153 |
| Slow queries | 0 |
| long_query_time | 10s |
| Slow query log | OFF |
| Buffer pool | 256 MB |
| Connections | 57 total, 1 active |

### 15.7 Application Weight

| Component | Size | Notes |
|-----------|------|-------|
| Core app files | 311 files | Not including vendor/plugins |
| Plugins (54) | 47 MB | 196 PHP + 130 JS |
| Vendor (Composer) | 105 MB | Largest: mpdf, workerman |
| Assets (CSS/JS/fonts) | 11.4 MB | 26 Bootstrap themes |
| **Total** | **~163 MB** | **3323 total files** |

### 15.8 Critical PHP Config Issues

| Setting | Current | Recommended | Severity |
|---------|---------|-------------|----------|
| upload_max_filesize | 2M | 20M | HIGH |
| post_max_size | 8M | 20M | HIGH |
| memory_limit | 128M | 256M | MEDIUM |
| max_execution_time | 30s | 60s | LOW |
| JIT buffer_size | 0 | 256M | LOW |
| interned_strings_buffer | 8 | 16-32 | LOW |
| validate_timestamps | On | Off (prod) | MEDIUM |

### 15.9 Bottleneck Ranking

1. upload_max_filesize=2M -- cannot upload medical reports/images
2. post_max_size=8M -- form submission limit too low for clinical data
3. OPcache.validate_timestamps=On -- unnecessary stat() overhead
4. JIT configured but buffer_size=0 -- JIT not functional
5. APCu 64MB allocated but ZERO utilization -- wasted resource
6. Cold cache first load 1.6s -- acceptable but improvable
7. Vendor 105MB -- mpdf/workerman font assets are bulk

---

## 16. Fase E — UI/UX Analysis

### 16.1 Frontend Stack

| Layer | Technology | Version |
|-------|------------|---------|
| CSS Framework | Bootstrap | 3.3.x (2013) |
| Themes | Bootswatch | 26 variants |
| Icons | Font Awesome | 4.x |
| JS Library | jQuery | 3.x |
| Table | DataTables | 1.x |
| Template Engine | Custom `{?...?}` syntax | — |
| PWA Support | Full manifest + icons | — |
| Custom JS | kalypto, selectator, scripts | 3.8 MB total |

### 16.2 Navigation Flow

```
Login (username/password)
  -> WhatsApp OTP (optional)
    -> Dashboard (Module Grid Modal + Top Navbar)
      -> Module selected
        -> IFrame/Full page
          -> CRUD operations
```

### 16.3 Workflow Depth (Rawat Jalan typical cycle)

```
Pasien List -> Search -> Select -> SOAP Note -> 
Diagnosa (ICD-10) -> Tindakan -> Resep -> 
Lab/Radiologi (optional) -> Billing -> SEP (optional)
```

~8-12 clicks per complete visit cycle.

### 16.4 UI Quality Assessment

| Aspek | Rating | Detail |
|-------|--------|--------|
| Login flow | Good | Clean, remember me, OTP option |
| Navigation | Fair | Modal grid + searchable module list |
| Mobile readiness | Good | PWA, responsive meta, touch icons |
| Theme variety | Excellent | 26 Bootstrap themes to choose from |
| Form design | Fair | Bootstrap 3 standard forms |
| Error handling | Fair | Server-side validation only |
| Loading states | Poor | No spinners/skeleton (Bootstrap 3 era) |
| Accessibility | Poor | No aria labels, no focus management |
| History management | Poor | Modal-based navigation breaks browser history |

### 16.5 Form Complexity

| Form | Fields | Pattern |
|------|--------|---------|
| Register Pasien | ~20 | Personal data + address + insurance |
| Rawat Jalan SOAP | ~15 | Subjective/Objective/Assessment/Plan |
| Billing | ~10 | Itemized with auto-calc |
| Resep Obat | ~8 | Drug search + dosage + quantity |
| Laboratorium | ~5 | Test selection + result entry |

### 16.6 Identified UI Issues

1. **Bootstrap 3** (2013) -- no flexbox utilities, end-of-life
2. **jQuery** -- no modern reactive framework (Vue/React)
3. **No loading indicators** -- forms appear blank while PHP processes
4. **No client-side validation** -- full POST round-trip for validation errors
5. **Modal stacking** -- modules load in modal, browser history/hyperlink unfriendly
6. **No keyboard shortcuts** -- no Ctrl+S, no tab-order optimization
7. **26 CSS themes fully loaded** -- user downloads all themes but only uses one
8. **Mobile touch targets** -- some form controls too small for touch

### 16.7 PWA Assessment

| Feature | Status |
|---------|--------|
| manifest.json | Present with full icon set (128-512px) |
| apple-mobile-web-app-capable | Yes |
| theme-color | #4C9A2A (green) |
| Service Worker | Configured (PWA installable) |

### 16.8 UI Recommendations

1. Pin a single active theme (disable 24 unused ones) to save bandwidth
2. Add loading overlay/spinner for AJAX-heavy operations
3. Add client-side validation (HTML5 `required` + jQuery validation plugin)
4. Consider Bootstrap 5 migration for modern grid/utilities/accessibility
5. Add keyboard shortcuts (Ctrl+S=Save, F5=Refresh search results)
6. Use breadcrumb navigation instead of modal stacking
7. On mobile, split long forms into wizard steps

---

*Dokumen ini adalah bagian dari proyek analisis dan dokumentasi mLITE SIMRS.*
*Repository: [github.com/adptra01/mlte-docs](https://github.com/adptra01/mlte-docs)*

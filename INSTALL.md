# INSTALL — Instalasi mLITE dari Nol

## Prasyarat

| Kebutuhan | Versi | Cara Cek |
|-----------|-------|----------|
| PHP | 7.4 – 8.3+ | `php -v` |
| Composer | 2.x | `composer --version` |
| MySQL / MariaDB | 5.7+ / 10+ | `mysql --version` |
| Web Server | Apache/Nginx | - |
| Redis (opsional) | 7.x | `redis-cli --version` |
| Atau: Docker | 20.10+ | `docker --version` |
| Atau: Podman | 4.0+ | `podman --version` |

## Metode 1: Local (PHP + Composer)

### Langkah
```bash
# 1. Buat proyek
composer create-project basoro/mlite
cd mlite

# 2. Folder permission
mkdir -p uploads tmp admin/tmp
chmod -R 777 uploads tmp admin/tmp systems/data

# 3. Konfigurasi
cp .env.example .env
# Edit .env sesuai environment Anda

# 4. Database
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS mlite CHARACTER SET utf8mb4;"
mysql -u root -p mlite < mlite_db.sql
# Penting: set sql-mode = '' di my.cnf

# 5. Install dependensi
composer install --no-dev

# 6. Jalankan
php -S localhost:8000
```

Akses: `http://localhost:8000` | Login: `admin`/`admin`

## Metode 2: Docker (Basic)

```bash
git clone https://github.com/basoro/mlite.git && cd mlite/docker
cp .env.example .env
docker compose up -d
```

Akses: `http://localhost:8088` | Login: `admin`/`admin`

## Metode 3: Docker (Optimized — Redis + MySQL tuning)

```bash
git clone https://github.com/basoro/mlite.git && cd mlite/docker
cp .env.test .env
docker compose -f compose.test.yaml up -d
```

Akses: `http://localhost:8088` | Login: `admin`/`admin`

Stack: Nginx (gzip) → PHP-FPM (APCu + opcache + JIT) → MySQL (tuned) → Redis (session)

## Metode 4: Podman

```bash
git clone https://github.com/basoro/mlite.git && cd mlite
cp .env.example .env

# Basic
podman-compose up -d

# Atau optimized
podman-compose -f docker/compose.test.yaml up -d
```

Akses: `http://localhost:8088` | Login: `admin`/`admin`

## Metode 5: Manual (tanpa Composer)

```bash
git clone https://github.com/basoro/mlite.git && cd mlite
wget https://getcomposer.org/download/latest/composer.phar
php composer.phar install --no-dev
# Lanjut ke Langkah 2-6 dari Metode 1
```

## Post-Install: Seed Data

Untuk demo dengan data dummy, import seed data setelah instalasi:

```bash
# Master tables
docker exec -i mlite-mysql-1 mysql -u root -prootpassword123 mlite_db < docker/seed_data.sql

# Operational data (kunjungan, resep, billing, dll)
docker exec -i mlite-mysql-1 mysql -u root -prootpassword123 mlite_db < docker/operational_seed.sql
```

Atau gunakan full DB dump yang sudah termasuk seed data:
```bash
docker exec -i mlite-mysql-1 mysql -u root -prootpassword123 mlite_db < docker/mlite_db_dump_with_seed.sql
```

## Environment Variables

### Basic (.env)
| Variable | Default | Deskripsi |
|----------|---------|-----------|
| `DBDRIVER` | `mysql` | `mysql` atau `sqlite` |
| `MYSQLHOST` | `localhost` | Host MySQL |
| `MYSQLUSER` | `root` | User MySQL |
| `MYSQLPASSWORD` | - | Password MySQL |
| `MYSQLDATABASE` | `mlite` | Nama database |
| `MYSQLPORT` | `3306` | Port MySQL |
| `APPURL` | `http://localhost:8000/uploads` | URL akses file |
| `DEVMODE` | `true` | Mode developer |

### Optimized (.env.test, tambahan)
| Variable | Default | Deskripsi |
|----------|---------|-----------|
| `REDIS_PASSWORD` | `mlite_redis_pass` | Password Redis |
| `CI_ENVIRONMENT` | `production` | CI4 environment mode |

## Verifikasi Setup Berhasil

1. Buka `http://localhost:8088` — halaman login muncul
2. Login dengan `admin`/`admin` — dashboard terbuka
3. Menu pasien, rawat jalan, farmasi dapat diakses

### Verifikasi Optimasi
```bash
# Cek Redis session
docker exec mlite-redis-1 redis-cli -a mlite_redis_pass PING
# Output: PONG

# Cek gzip compression
curl -H "Accept-Encoding: gzip" -I http://localhost:8088/ | grep -i "content-encoding"

# Cek MySQL indexes
docker exec mlite-mysql-1 mysql -uroot -prootpassword123 mlite_db -e "
SELECT TABLE_NAME, INDEX_NAME FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'mlite_db' AND INDEX_NAME LIKE 'idx_%';
"
```

## Troubleshooting

| Masalah | Solusi |
|---------|--------|
| Blank page | Set `DEVMODE=true`, cek PHP error log |
| DB connection refused | Pastikan MySQL running, host/port benar |
| Table not found | Import `mlite_db.sql` |
| 403 Forbidden | Cek Nginx config `systems/data/` |
| Login gagal | Reset: `UPDATE users SET password = MD5('admin') WHERE username='admin'` |
| Redis connection failed | Pastikan Redis container running, check password |
| Slow queries | Cek MySQL indexes dengan `EXPLAIN SELECT ...` |

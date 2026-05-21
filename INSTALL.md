# INSTALL — Instalasi mLITE dari Nol

## Prasyarat

| Kebutuhan | Versi | Cara Cek |
|-----------|-------|----------|
| PHP | 7.4 – 8.3+ | `php -v` |
| Composer | 2.x | `composer --version` |
| MySQL / MariaDB | 5.7+ / 10+ | `mysql --version` |
| Web Server | Apache/Nginx | - |
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

## Metode 2: Docker

```bash
git clone https://github.com/basoro/mlite.git && cd mlite
cp .env.example .env
docker compose up -d
```

Akses: `http://localhost:8088` | Login: `admin`/`admin`

## Metode 3: Podman

```bash
git clone https://github.com/basoro/mlite.git && cd mlite
cp .env.example .env
podman-compose up -d
```

Akses: `http://localhost:8088` | Login: `admin`/`admin`

## Metode 4: Manual (tanpa Composer)

```bash
git clone https://github.com/basoro/mlite.git && cd mlite
wget https://getcomposer.org/download/latest/composer.phar
php composer.phar install --no-dev
# Lanjut ke Langkah 2-6 dari Metode 1
```

## Environment Variables

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

## Verifikasi Setup Berhasil

1. Buka `http://localhost:8088` — halaman login muncul
2. Login dengan `admin`/`admin` — dashboard terbuka
3. Menu pasien, rawat jalan, farmasi dapat diakses

## Troubleshooting

| Masalah | Solusi |
|---------|--------|
| Blank page | Set `DEVMODE=true`, cek PHP error log |
| DB connection refused | Pastikan MySQL running, host/port benar |
| Table not found | Import `mlite_db.sql` |
| 403 Forbidden | Cek Nginx config `systems/data/` |
| Login gagal | Reset: `UPDATE users SET password = MD5('admin') WHERE username='admin'` |

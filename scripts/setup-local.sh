#!/bin/bash
# setup-local.sh — Setup mLITE secara lokal (PHP native)
# Usage: ./scripts/setup-local.sh

set -e

echo "=== mLITE Local Setup ==="

command -v php >/dev/null 2>&1 || { echo "PHP not found"; exit 1; }
command -v composer >/dev/null 2>&1 || { echo "Composer not found"; exit 1; }

cd "$(dirname "$0")/.."

# Clone jika belum
[ -f "composer.json" ] || git clone https://github.com/basoro/mlite.git .

composer install --no-dev --no-interaction
mkdir -p uploads tmp admin/tmp systems/data
chmod -R 777 uploads tmp admin/tmp systems/data

if [ ! -f ".env" ]; then
    cat > .env << 'EOF'
DBDRIVER=mysql
MYSQLHOST=localhost
MYSQLUSER=root
MYSQLPASSWORD=
MYSQLDATABASE=mlite
MYSQLPORT=3306
APPURL=http://localhost:8000/uploads
DEVMODE=true
EOF
    echo ".env created — edit with your DB credentials"
fi

echo ""
echo "=== Selesai ==="
echo "1) Buat database: mysql -u root -p -e 'CREATE DATABASE mlite;'"
echo "2) Import data: mysql -u root -p mlite < mlite_db.sql"
echo "3) Set sql-mode='' in my.cnf"
echo "4) Jalankan: php -S localhost:8000"
echo "5) Akses: http://localhost:8000 | admin/admin"

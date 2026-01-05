#!/bin/bash

set -e

NAMESPACE="vidmanager"
POD_NAME="mysql-0"
DB_NAME="VIDMANAGER"
ROOT_SECRET="mysql-secret"
ADMIN_SECRET="mysql-admin-secret"
ADMIN_USER="admin"

echo "🔐 Retrieving MySQL root password..."
MYSQL_ROOT_PASSWORD=$(microk8s kubectl get secret $ROOT_SECRET -n $NAMESPACE \
  -o jsonpath="{.data.mysql-root-password}" | base64 --decode)

if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
  echo "❌ ERROR: Root password not found"
  exit 1
fi

echo "🔐 Retrieving MySQL admin password..."
MYSQL_ADMIN_PASSWORD=$(microk8s kubectl get secret $ADMIN_SECRET -n $NAMESPACE \
  -o jsonpath="{.data.mysql-admin-password}" | base64 --decode)

if [ -z "$MYSQL_ADMIN_PASSWORD" ]; then
  echo "❌ ERROR: Admin password not found"
  exit 1
fi

echo "🚀 Connecting to MySQL pod and applying configuration..."

microk8s kubectl exec -i $POD_NAME -n $NAMESPACE -- \
mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<EOF

-- 1. Ensure database exists
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;

-- 2. Show databases
SHOW DATABASES;

-- 3. Ensure admin user exists
CREATE USER IF NOT EXISTS '$ADMIN_USER'@'%' IDENTIFIED BY '$MYSQL_ADMIN_PASSWORD';

-- 4. Grant full privileges on VIDMANAGER schema
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$ADMIN_USER'@'%';

-- 5. Apply privilege changes
FLUSH PRIVILEGES;

-- 6. List users
SELECT user, host FROM mysql.user;

EOF

echo "✅ Database and user setup completed successfully."

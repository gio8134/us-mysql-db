#!/bin/bash

NAMESPACE="vidmanager"
POD_NAME="mysql-0"
DB_NAME="VIDMANAGER"
ADMIN_USER="admin"
ADMIN_SECRET="mysql-admin-secret"

echo "🔐 Retrieving MySQL admin password..."

MYSQL_ADMIN_PASSWORD=$(microk8s kubectl get secret $ADMIN_SECRET -n $NAMESPACE \
  -o jsonpath="{.data.mysql-admin-password}" | base64 --decode)

if [ -z "$MYSQL_ADMIN_PASSWORD" ]; then
  echo "❌ ERROR: Could not retrieve admin password"
  exit 1
fi

echo "🚀 Connecting to MySQL database '$DB_NAME' as user '$ADMIN_USER'..."

microk8s kubectl exec -it $POD_NAME -n $NAMESPACE -- \
  mysql -u "$ADMIN_USER" -p"$MYSQL_ADMIN_PASSWORD" "$DB_NAME"

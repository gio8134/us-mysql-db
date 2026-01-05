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

echo "🚀 Connecting to MySQL and ensuring table VIDEOSOURCES exists..."

microk8s kubectl exec -i $POD_NAME -n $NAMESPACE -- \
mysql -u "$ADMIN_USER" -p"$MYSQL_ADMIN_PASSWORD" "$DB_NAME" <<EOF

CREATE TABLE IF NOT EXISTS VIDEOSOURCES (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    video_name VARCHAR(255) NOT NULL,
    volume_path VARCHAR(255) NOT NULL,
    INDEX idx_video_name (video_name),
    INDEX idx_volume_path (volume_path)
);

SHOW TABLES;

EOF

echo "✅ Table VIDEOSOURCES checked/created successfully."

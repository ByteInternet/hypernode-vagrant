#!/usr/bin/env bash
set -e

echo "Get the uploaded scripts out of the way of the webroot"
mkdir -p /data/web/uploaded
if [ -f /data/web/public/scripts/install_magento_2.yml ]; then
    cp /data/web/public/scripts/* /data/web/uploaded
    rm -Rf /data/web/public
fi
cd /data/web/uploaded

echo "Gathering the server variables"
HOST_IP_ADDR=$(ifconfig `find /sys/class/net \( -name 'eth*' -o \
  -name 'enp*' \) -printf '%f\n' | sort | tail -n 1` | \
  grep 'inet addr:' | cut -d: -f2 | awk '{print$1}')
MYSQL_PWD=$(grep password /data/web/.my.cnf | awk '{print$NF}')
cat <<EOF > /data/web/uploaded/magento_2_vars.yml
magento_installation_path: "/data/web/magento2"
magento_database_name: "magento"
magento_database_host: "mysqlmaster"
magento_database_user: "app"
magento_database_password: "$MYSQL_PWD"
magento_backend_frontname: "admin"
magento_base_url: "http://$HOST_IP_ADDR"
magento_language: "en_US"
magento_timezone: "Europe/Amsterdam"
magento_currency: "EUR"
magento_admin_lastname: "admin"
magento_admin_firstname: "admin"
magento_admin_email: "admin@example.com"
magento_admin_user: "admin"
magento_admin_password: "admin1234"
magento_use_rewrites: "1"
EOF

echo "Running the idempotent Magento 2 installation playbook"
ansible-playbook /data/web/uploaded/install_magento_2.yml \
    --extra-vars "@/data/web/uploaded/magento_2_vars.yml" \
    --connection=local --connection=local -i '127.0.0.1,'

echo "Point your browser to http://$HOST_IP_ADDR for the Magento 2 installation"

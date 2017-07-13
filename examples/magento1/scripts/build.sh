#!/usr/bin/env bash
set -e

echo "Gathering the server variables"
HOST_IP_ADDR=$(ifconfig `find /sys/class/net \( -name 'eth*' -o \
  -name 'enp*' \) -printf '%f\n' | sort | tail -n 1` | \
  grep 'inet addr:' | cut -d: -f2 | awk '{print$1}')
MYSQL_PWD=$(grep password /data/web/.my.cnf | awk '{print$NF}')
cat <<EOF > /data/web/public/scripts/magento_1_vars.yml
magento_installation_path: "/data/web/public"
magento_baseurl: "http://$HOST_IP_ADDR"
admin: 
  first_name: "Firstname"
  last_name: "Lastname"
  password: "thisisanexamplePassword123456"
  locale: "en_US"
  email: "example@example.com"
admin_password: "thisisanexamplePassword123456"
admin_frontname: "test"
mysqlhost: "mysqlmaster"
mysql_app_user: "app"
mysql_app_password: "$MYSQL_PWD"
magento_db: "magento"
EOF


echo "Running the idempotent Magento 1 installation playbook"
ansible-playbook /data/web/public/scripts/install_magento_1.yml \
    --extra-vars "@/data/web/public/scripts/magento_1_vars.yml" \
    --connection=local --connection=local -i '127.0.0.1,' \
    --verbose

echo "Point your browser to http://$HOST_IP_ADDR for the Magento installation"

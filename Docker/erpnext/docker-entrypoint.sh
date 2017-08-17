#!/bin/sh
bench use localhost

# setup site_config.json
/usr/local/bin/dockerize -template /tmp/config/site_config.json.tmpl:/home/$FRAPPE_USER/frappe-bench/sites/common_site_config.json \
          -template /tmp/config/site_config.json.tmpl:/home/$FRAPPE_USER/frappe-bench/sites/localhost/site_config.json \
          true

# set permissions on config files
chmod 440 /home/$FRAPPE_USER/frappe-bench/sites/common_site_config.json \
          /home/$FRAPPE_USER/frappe-bench/sites/localhost/site_config.json


echo 'Waiting for DB to start up'
/usr/local/bin/dockerize -wait tcp://db:3306 -timeout 120s

echo 'Erpnext install'
cd /home/frappe/frappe-bench && \
bench get-app erpnext $ERPNEXT_REPO --branch $ERPNEXT_BRANCH && \
bench install-app erpnext && \
supervisor -c /etc/supervisor.conf
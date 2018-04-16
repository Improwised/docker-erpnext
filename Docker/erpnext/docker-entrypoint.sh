#!/bin/sh
# setup site_config.json
mv Procfile_docker Procfile

/usr/local/bin/dockerize -template /tmp/config/site_config.json.tmpl:/home/$FRAPPE_USER/frappe-bench/sites/common_site_config.json
cp /home/$FRAPPE_USER/frappe-bench/sites/common_site_config.json /home/$FRAPPE_USER/frappe-bench/sites/localhost/site_config.json


# set permissions on config files
chown $FRAPPE_USER:$FRAPPE_USER /home/$FRAPPE_USER/frappe-bench/sites/common_site_config.json /home/$FRAPPE_USER/frappe-bench/sites/localhost/site_config.json
chmod 440 /home/$FRAPPE_USER/frappe-bench/sites/common_site_config.json /home/$FRAPPE_USER/frappe-bench/sites/localhost/site_config.json

echo 'Waiting for DB to start up'
/usr/local/bin/dockerize -wait tcp://db:3306 -timeout 120s

echo 'Erpnext install'
bench set-mariadb-host mariadb
bench new-site $ERPNEXT_SITE
bench --site $ERPNEXT_SITE install-app erpnext

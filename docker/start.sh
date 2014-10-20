#!/bin/bash

if [ ! -f /mysql_is_installed ]; then
  echo "Installing database..."
  mysql_install_db --user=mysql >/dev/null 2>&1

  # start mysql server
  echo "Starting MySQL server..."
  /usr/bin/mysqld_safe >/dev/null 2>&1 &

  sleep 10s

  mysqladmin -u root password admin
  mysqladmin -u root --password=admin shutdown
  sleep 10s
  touch /mysql_is_installed
fi


if [ ! -f "${WEB_ROOT}/sites/default/settings.php" ]; then

  # Start mysql
  /usr/bin/mysqld_safe &
  sleep 10s
  # Generate passwords
  DRUPAL_DB="drupal"
  MYSQL_PASSWORD='admin'
  DRUPAL_PASSWORD='admin'


  if [ -n "${NO_INSTALL}" ]; then
    echo "skipping drupal setup, please setup manually."
    echo "mysql-user: admin drupal-user: admin pass: admin"
  else
    echo "setup drupal in ${WEB_ROOT}"
    mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE drupal; GRANT ALL PRIVILEGES ON drupal.* TO 'drupal'@'localhost' IDENTIFIED BY '$DRUPAL_PASSWORD'; FLUSH PRIVILEGES;"
    chmod 755 "${WEB_ROOT}/sites/default"
    cd "${WEB_ROOT}"
    drush site-install minimal -y --account-name=admin --account-pass=admin --db-url="mysqli://drupal:${DRUPAL_PASSWORD}@localhost:3306/drupal"
    drush en ${PROJECT_NAME}_deploy

  fi
  killall mysqld
  sleep 10s

fi
supervisord -n

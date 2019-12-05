#!/usr/bin/env bash

# Dependencies installed in _dependencies.sh to reduce unnecessary apt updates

echo ">>> Installing MySQL"

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

sudo apt-get install -y vim curl python-software-properties mysql-server

echo "Open MySQL bind address"
sed -i "s/^bind-address/#bind-address/" /etc/mysql/mysql.conf.d/mysqld.cnf

echo "Increase Max Packet Size to support our large migrations"
sed -i "s/^max_allowed_packet.*=.*16M/max_allowed_packet    = 100M/g" /etc/mysql/mysql.conf.d./mysqld.cnf

echo "Set default time zone to Pacific"
sed '/skip-external-locking/a default-time-zone = "-08:00"' /etc/mysql/mysql.conf.d/mysqld.cnf
echo 'sql-mode="STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION"' >> /etc/mysql/mysql.conf.d/mysqld.cnf

echo "Set privileges and create LocalData Database"
mysql -u root -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES; CREATE DATABASE LocalData; SET GLOBAL sql_mode = 'NO_ENGINE_SUBSTITUTION';"

sudo /etc/init.d/mysql restart
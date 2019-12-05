#!/usr/bin/env bash

# Dependencies installed in _dependencies.sh to reduce unnecessary apt updates

echo ">>> Installing MongoDB"

# Install MongoDB
# -qq implies -y --force-yes
sudo apt-get install -qq mongodb-org

# Make MongoDB connectable from outside world without SSH tunnel
if [ $1 == "true" ]; then
    echo "Opening Mongo for remote access"

    # enable remote access
    # setting the mongodb bind_ip to allow connections from everywhere
    sudo sed -i "s/bindIp: .*/bindIp: 0.0.0.0/" /etc/mongod.conf
fi

# Test if PHP is installed
php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$?

if [ $PHP_IS_INSTALLED -eq 0 ]; then
    # install dependencies
    sudo apt-get -y install php-pear php5-dev

    # install php extension
    echo "no" > answers.txt
    sudo pecl install mongo < answers.txt
    rm answers.txt

    # add extension file and restart service
    echo 'extension=mongo.so' | sudo tee /etc/php5/mods-available/mongo.ini

    ln -s /etc/php5/mods-available/mongo.ini /etc/php5/fpm/conf.d/mongo.ini
    ln -s /etc/php5/mods-available/mongo.ini /etc/php5/cli/conf.d/mongo.ini
    sudo service php5-fpm restart
fi

echo "Restarting Mongo DB"
sudo service mongod restart
sleep 20
echo "Wait complete, creating users: root"
mongo admin --eval 'db.createUser({user: "root", pwd: "root", roles: [{ role: "root", db: "admin" }]})'
echo "If the mongo user creation step fails: the commands can be run using 'vagrant ssh' then using lines 45-48 in _install/mongo.sh"

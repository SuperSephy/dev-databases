#!/usr/bin/env bash

# Dependencies installed in _dependencies.sh to reduce unnecessary apt updates

echo ">>> Install java first"

sudo apt-get install default-jdk

echo ">>> Installing elasticsearch"

sudo apt-get -y install elasticsearch

echo ">>> Install config file from /elasticsearch into vagrant vm"

sudo cp /vagrant/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
sudo chmod 760 /etc/elasticsearch/elasticsearch.yml
sudo chown root:elasticsearch /etc/elasticsearch/elasticsearch.yml

echo ">>> Restart elasticsearch service to pick up new config"

sudo service elasticsearch restart

echo ">>> Set elasticsearch service to start automatically on boot"

sudo update-rc.d elasticsearch defaults 95 10
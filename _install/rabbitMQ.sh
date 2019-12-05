#!/usr/bin/env bash

# Dependencies installed in _dependencies.sh to reduce unnecessary apt updates

echo ">>> Installing RabbitMQ"

#apt-get install -y erlang erlang-nox --force-yes 	# Precise 64 Build 

# --force-yes deprecated and replaced by --allow-downgrades, --allow-remove-essential, --allow-change-held-packages
# see https://manpages.debian.org/stretch/apt/apt-get.8.en.html
apt-get install -y rabbitmq-server --allow-downgrades --allow-remove-essential --allow-change-held-packages

rabbitmqctl add_user root root
rabbitmqctl set_permissions -p / root ".*" ".*" ".*"
rabbitmqctl set_user_tags root administrator

# RabbitMQ Plugins
service rabbitmq-server stop
rabbitmq-plugins enable rabbitmq_management
service rabbitmq-server start
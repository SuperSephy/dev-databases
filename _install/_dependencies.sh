#!/usr/bin/env bash

# Run Update
sudo apt-get update

# Install PPA and debconf dependencies first
sudo apt-get install -y python-software-properties debconf-utils

echo ">>> Updating apt-get repositories for all dependencies"

# MONGO
	# Install gnupg and its required libraries using the following command
	sudo apt-get install gnupg
	
	# Import the MongoDB public GPG Key
	wget -qO - https://www.mongodb.org/static/pgp/server-3.6.asc | sudo apt-key add

	# Make MongoDB connectible from outside world without SSH tunnel
	echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list

# MySQL
	# None 

# RabbitMQ
	# Precise 64 Build (Ubuntu 12.04 - Latest RabbitMQ requires 14.04)
		# echo "deb http://packages.erlang-solutions.com/ubuntu precise contrib" >> /etc/apt/sources.list
		# echo "deb http://www.rabbitmq.com/debian/ testing main" > /etc/apt/sources.list.d/rabbitmq.list

		# Expired Precise64 Key
		#wget http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
		#apt-key add rabbitmq-signing-key-public.asc

	# Trusty64 Build	
		# echo "deb http://packages.erlang-solutions.com/ubuntu xenial contrib" >> /etc/apt/sources.list
		echo 'deb http://www.rabbitmq.com/debian/ testing main' | sudo tee /etc/apt/sources.list.d/rabbitmq.list

		# New Key
		sudo apt-key adv --keyserver "hkps.pool.sks-keyservers.net" --recv-keys "0x6B73A36E6026DFCA" -
		wget -O- "https://www.rabbitmq.com/rabbitmq-release-signing-key.asc" | sudo apt-key add -

# Redis
	# Add repository
	# sudo apt-add-repository ppa:rwky/redis -y 			# 2.8.4 - Deprecated, need 2.8.9+ for ZRANGEBYLEX
	sudo add-apt-repository ppa:chris-lea/redis-server -y 	# 3.2.*

# Elasticsearch
	# Add repository
	wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
	echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list

# Run Update
sudo apt-get update

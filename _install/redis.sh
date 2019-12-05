#!/usr/bin/env bash

# Dependencies installed in _dependencies.sh to reduce unnecessary apt updates

echo ">>> Installing Redis"

# Install Redis
# -qq implies -y --force-yes
sudo apt-get install -qq redis-server

# Redis Configuration
sudo mkdir -p /etc/redis/conf.d

# transaction journaling - config is written, only enabled if persistence is requested
cat << EOF | sudo tee /etc/redis/conf.d/journaling.conf
appendonly yes
appendfsync everysec
EOF

# Persistence
if [ ! -z "$1" ]; then
	if [ "$1" == "persistent" ]; then
		echo ">>> Enabling Redis Persistence"

		# add the config to the redis config includes
		if ! cat /etc/redis/redis.conf | grep -q "journaling.conf"; then
			sudo echo "include /etc/redis/conf.d/journaling.conf" >> /etc/redis/redis.conf
		fi

		# schedule background append rewriting
		if ! crontab -l | grep -q "redis-cli bgrewriteaof"; then
			line="*/5 * * * * /usr/bin/redis-cli bgrewriteaof > /dev/null 2>&1"
			(sudo crontab -l; echo "$line" ) | sudo crontab -
		fi
	fi # persistent
fi # arg check

# Expose ports for host to connect to vagrant
sudo mv /etc/redis/redis.conf /etc/redis/redis.conf.old
echo "bind 0.0.0.0" | sudo tee /etc/redis/redis.conf
cat /etc/redis/redis.conf.old | grep -v bind | sudo tee -a /etc/redis/redis.conf
sudo service redis-server restart
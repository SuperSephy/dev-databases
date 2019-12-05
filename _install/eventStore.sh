#!/usr/bin/env bash

# Dependencies installed in _dependencies.sh to reduce unnecessary apt updates

    echo ">>> Installing EventStore"

# Install EventStore
# -qq implies -y --force-yes
    curl -s https://packagecloud.io/install/repositories/EventStore/EventStore-OSS/script.deb.sh | bash

    apt-get install eventstore-oss

    echo "---
    IntIp: 0.0.0.0
    ExtIp: 0.0.0.0
    IntHttpPrefixes: http://*:2112/
    ExtHttpPrefixes: http://*:2113/
    AddInterfacePrefixes: false
    RunProjections: All" > /etc/eventstore/eventstore.conf

    service eventstore start

# Accessible using http://33.33.33.10:2113/
# admin / changeit
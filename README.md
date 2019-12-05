# Development Environment Databases

Uses Vagrant to create an Ubuntu box with MongoDB, MySQL, RabbitMQ, Redis, and Elasticsearch installed, and loads development data migrations.


## Pre-requisites

### Mac/Win
Before launching your DB environment, you must install VirtualBox as well as Vagrant. 
All of these software packages provide easy-to-use visual installers for all popular operating systems.

* Install [Vagrant](http://www.vagrantup.com/downloads.html)
  * Rename `/Vagrantfile_DEFAULT` to just `Vagrantfile`.
  * After that, it should be a straightforward download and install.
  * 11/10/16 - For Mac Vagrant 1.8+ and VirtualBox 5.1+, you may also need to `sudo rm /opt/vagrant/embedded/bin/curl`. Otherwise try lower versions like Vagrant 1.7.4 and VirtualBox 5.0.28. Vagrant's own curl lib tends to fail at `vagrant up` when downloading the box.
* Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
  * Should be a straightforward download and install. If issues on Mac High Sierra, see note at bottom.
* Note: MongoDB, MySQL, and RabbitMQ installed on virtual machine during vagrant set-up 
  * [MongoDB](https://docs.mongodb.org/manual/installation/) 
  * [MySQL](http://dev.mysql.com/doc/refman/5.7/en/installing.html)
  * [RabbitMQ](https://www.rabbitmq.com/download.html)
  
Note: If you are using Windows, you may need to enable hardware virtualization (VT-x). It can usually be enabled via your BIOS. 
If you are using Hyper-V on a UEFI system you may additionally need to disable Hyper-V in order to access VT-x.
You should be able to disable Hyper-V using the command below (as Admin) and then restarting.

```
bcdedit /set hypervisorlaunchtype off
```

---

### Ubuntu

The solution described requires four components:

* **libvirt** provides an abstraction language to define and launch VMs, but is normally used just to launch single VMs. It uses XML to represent and define the VM.
* **KVM** works exclusively with QEMU and  performs hardware acceleration for x86 VMs with Intel and AMD CPUs. KVM and QEMU are hypervisors that emulate the VMs; the pair is often called KVM/QEMU or just KVM.
* **QEMU** is a machine emulator that can allow the host machine to emulate the CPU architecture of the guest machine. Because QEMU does not provide hardware acceleration, it works well with KVM.
* **Vagrant** is an orchestration tool that makes it easier to manage groups of VMs by interconnecting them programmatically. Vagrant helps to tie all the components together and provides a user-friendly language to launch suites of VMs. Vagrant allows multiple Cumulus VX VMs to be interconnected to simulate a network. Vagrant also allows Cumulus VX VMs to be interconnected with other VMs (such as Ubuntu or CentOS) to emulate real world networks.
  * You must install Vagrant **after** you install libvirt. Vagrant might not properly detect the necessary files if it is installed before libvirt. Cumulus VX requires version 1.7 or later. Version 1.9.1 or later is recommended.

#### Install libvirt

Check the Linux version of the host. This guide is validated and verified for Ubuntu 16.04 LTS starting from a clean install: 

```shell script
user@ubuntubox:~$ lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 16.04 LTS
Release:    16.04
Codename:   xenial

user@ubuntubox:~$ uname -a
Linux ubuntubox 4.4.0-22-generic #40-Ubuntu SMP Thu May 12 22:03:46 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
    
```

After verifying the version, install libvirt and QEMU. The following commands install the necessary components to get libvirt and QEMU operational.

```shell script
user@ubuntubox:~$ sudo apt-get update -y
user@ubuntubox:~$ sudo apt-get install libvirt-bin libvirt-dev qemu-utils qemu
user@ubuntubox:~$ sudo /etc/init.d/libvirt-bin restart
```

After the installation completes, log out, then log in and verify the libvirt version. 

```shell script
user@ubuntubox:~$ libvirtd --version

libvirtd (libvirt) 1.3.1
libvirt versions 1.2.20 or higher have native support for the UDP tunnels, which are used for the point-to-point links in VM simulation.
```    
Add your user to the libvirtd group (if not already present) so your user can perform virsh commands. 

```shell script
user@ubuntubox:~$ sudo usermod -a -G libvirtd USERNAME

To apply the new group to your existing user, log out and in again.
```

Confirm that your Linux kernel and BIOS settings permit the use of KVM hardware acceleration.

```shell script
user@ubuntubox:~$ kvm-ok

INFO: /dev/kvm exists

KVM acceleration can be used
```

After completing these steps, libvirt and KVM/QEMU are installed. The Linux server is now ready to run VMs.

Install Vagrant
---------------

You must install Vagrant **after** you install libvirt. Vagrant might not properly detect the necessary files if it is installed before libvirt. Cumulus VX requires version 1.7 or later. Version 1.9.1 or later is recommended.

Rename `/Vagrantfile_DEFAULT` OR `/Vagrantfile_UBUNTU` to just `Vagrantfile` (depending on your OS). 

Install Vagrant from the deb package. In this guide, Vagrant version 1.9.3 is used.
  
Ubuntu Shell Scripts (Mac and Windows should use the Installer)
```shell script    
user@ubuntubox:~$ wget [https://releases.hashicorp.com/vagrant/1.9.3/vagrant_1.9.3_x86_64.deb](https://releases.hashicorp.com/vagrant/1.9.3/vagrant_1.9.3_x86_64.deb)
--2017-06-23 20:01:43--  [https://releases.hashicorp.com/vagrant/1.9.3/vagrant_1.9.3_x86_64.deb](https://releases.hashicorp.com/vagrant/1.9.3/vagrant_1.9.3_x86_64.deb)

Resolving releases.hashicorp.com (releases.hashicorp.com)... 151.101.129.183, 151.101.193.183, 151.101.1.183, ...
Connecting to releases.hashicorp.com (releases.hashicorp.com)|151.101.129.183|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 87666544 (84M) [application/x-debian-package]
Saving to: ‘vagrant_1.9.3_x86_64.deb’
vagrant_1.9.3_x86_64.deb

2017-06-23 20:03:02 (1.07 MB/s) - ‘vagrant_1.9.3_x86_64.deb’ saved [87666544/87666544]
```
    
Install Vagrant using dpkg (Mac and Windows should use the Installer):
    
```shell script
user@ubuntubox:~$ sudo dpkg -i vagrant_1.9.3_x86_64.deb
Selecting previously unselected package vagrant.
(Reading database ... 99162 files and directories currently installed.)
Preparing to unpack vagrant_1.9.3_x86_64.deb ...
Unpacking vagrant (1:1.9.3) ...
Setting up vagrant (1:1.9.3) ...
```
    
Verify the Vagrant version:

```shell script
user@ubuntubox:~$ vagrant --version
Vagrant 1.9.3
```
    
Install the necessary plugins for Vagrant (Ubuntu only).

But first, you'll need to install ruby-dev if you don't have it: `sudo apt-get install ruby-dev`
    
 ```shell script
user@ubuntubox# vagrant plugin install vagrant-mutate

Installing the 'vagrant-mutate' plugin. This can take a few minutes...
Installed the plugin 'vagrant-mutate (1.2.0)'!
user@ubuntubox# vagrant plugin install vagrant-libvirt
Installing the 'vagrant-libvirt' plugin. This can take a few minutes...
Installed the plugin 'vagrant-libvirt (0.0.35)'!
Vagrant plugin installation is unique to each user; make sure to install plugins as the user who will run the simulations.
```
---

## Usage

Once VirtualBox/libvert, and Vagrant are installed - you should be able to run the `vagrant up` command and the container should build.
If you have any issues, you may have to rely on some debugging, please notate any fixes here to keep everyone else informed as well!

> Note: The mongo user creation step is called after an arbitrary 20 seconds to allow the service time to restart after changing the etc/mongod.conf - depending on your machine this may still not be long enough. You can either elongate the sleep time in the mongo-install.sh file or use `vagrant ssh` followed by `mongo` to run lines 8-10 starting at the `db.createUser` to achieve the same effect.

### Migration Setup

Install
 ```shell script
$ npm install
```

#### Preferred Install/Start - runs `vagrant up` and refreshes migrations for you
 
```shell script
$ ./run.sh
``` 

#### Install version 2 - Each command independently

```shell script
$ vagrant up
$ npm run mysql
$ npm run mongo
```

#### Refresh databases (empties databases and re-seeds)

```shell script
$ ./refresh.sh
```


## Services

### MySQL

MySQL is installed as part of the Vagrant Provision.

```
# Run "vagrant up" from this directory to get MySQL up (and "vagrant suspend || vagrant halt" to bring it down)
```

Connect via command line (if you have the MySQL CLI installed)

```
mysql -h 33.33.33.10 -uroot -proot -P 3306
```

Connect via MySQL Workbench, configure a new connection

```
host: 33.33.33.10
port: 3306
user: root
password: root

```

MySQL created with "LocalData" as Database and "root" as the User.

```
"mysql":{
    "host":"33.33.33.1",
    "port": 3306,
    "user":"root",
    "password":"root",
    "database":"LocalData"
},

```

#### How to make a MySQL migration

See example in `migrations/mysql`

##### File Naming Convention 

- __PREFIX__ (Required)
  + File Names MUST start with at least 12 numbers (default YYYYMMDDhhmmss)
  + This is what the `db-migrate` package uses to look for migration files
- __PRIORITY__
  + __Numbers__
    * Numbers indicate run cardinality - Whether certain migrations should be run before others. For example, some tables like `comments` may depend on the `users` table being created first.
  + __A__
    * `A` indicates that the migration contains an `ALTER` command, modifying one of the existing tables. 

```
#### http://umigrate.readthedocs.org/projects/db-migrate/en/v0.9.x/

#### this makes an empty migration called "sample_migration_name"
node node_modules/db-migrate/bin/db-migrate create sample_migration_name --config "./migrations/database.json" -m "./migrations/migrations"

#### paste mysql workbench dumps into the sql files

```

Run all MySQL migrations

```
node node_modules/db-migrate/bin/db-migrate up --config "./migrations/database.json"
```

How to seed MySQL

```

#### run a migration that includes data
```

##### Revert MySQL 

Notes:

- Down 
  + Only rolls back the most recent migration, 1 at a time.
- Reset
  + Deletes all databases and removes them from the migrations table.

```
npx db-migrate down --config "./migrations/database.json" -m migrations/{TYPE} -e dev-{TYPE}

# OR

npx db-migrate reset --config "./migrations/database.json" -m migrations/{TYPE} -e dev-{TYPE}

```


#### GUI 

[MySQL Workbench](https://www.mysql.com/products/workbench/) and [Sequel Pro](http://www.sequelpro.com/) are both recommended.


### MongoDB 

MongoDB is installed as part of the Vagrant Provision.

#### Connect

```
# From your terminal: 
mongo LocalData --host 33.33.33.10 -uroot -proot --authenticationDatabase "admin"

# From Vagrant box (i.e. after running `vagrant ssh`)
mongo LocalData -u "root" -p "root" --authenticationDatabase "admin"
```

#### Vagrant Provision Creates: 

- __Users__:
  + admin (root)
- __Databases__:
  + LocalData

#### Make a database

```
use newDatabaseName
```

#### Create a user (root user created for you)

```
db.createUser(
    {
      user: "userName",
      pwd: "passwordValue",
      roles: [
         { role: "readWrite", db: "newDatabaseName" }
      ]
    })
```

Reference the MongoDB in the dev area of your project.

```
#### sample config.json for mongodb

"mongodb":{
    "host":"33.33.33.10",
    "port":27017,
    "user":"root",
    "password":"root",
    "authSource":"admin"        # authentication Database
},

```

#### Patch to put users in admin collection instead of directly on collections

```
vagrant ssh

mongo collectionName -u "root" -p "root" --authenticationDatabase "admin"

#### clear previous

use collectionName
db.dropUser("userName")

#### create users on admin collection instead

use admin

db.createUser({ 
  user: "sample",
  pwd: "sample123",
  roles: [ 
    { role: "read", db: "admin" },
    { role: "readWrite", db: "LocalData" },
  ] 
})

```

#### How to make a MongoDB migration

See example provided in `migrations/mongo`

#### Mongo Tools

Mongo Dump

```
mongodump --db=LocalData --host 33.33.33.10 -uroot -proot --authenticationDatabase "admin" -o mongodump
```

Mongo Top

```
mongotop -h 33.33.33.10:27017 -u 'root' -p 'root' --authenticationDatabase 'admin'
```

Mongo Stat

```
mongostat -h 33.33.33.10:27017 -u 'root' -p 'root' --authenticationDatabase 'admin'
```

### GUI

[Robomongo](https://robomongo.org/download) seems to be a pretty functional GUI for accessing the DB in a visual way.

### EventStore

- http://33.33.33.10:2113/web/index.html#/
- `admin` / `changeit` (default)

### RabbitMQ

#### Admin Panel

You can access the RabbitMQ admin panel via a web browser using the url `http://33.33.33.10:15672/` OR `localhost:15672/` and the `root` / `root` username/password.

As this serves as our messaging/task running service, there are no seed to pre-load, but an example implementation has been provided in the rabbitMQ subdirectory.

Recommended usage:

With the vagrant box running, initialize as many listeners as you like using separate terminals using the following command:
`$ DEBUG=* node ./rabbitMQ/worker.js`
You should see terminal output showing a successful connection and that the worker is waiting for an input.

Then you can run an instance of `$ DEBUG=* node ./rabbitMQ/send.js` and see the message sent from one terminal and recieved round-robin by the workers you started up before.

### Redis

If you install the redis-cli (installed during redis install `brew install redis`) you can access the service from the host machine using:
`$ redis-cli`
and confirm connection using the `$ ping` -> `PONG` response.

Not many GUI options, but after trying a few [FastoRedis](http://www.fastoredis.com/) seems ok. 

### ElasticSearch

Basic install of ElasticSearch. No GUI option yet.

Custom config values (in this repo /elasticsearch/elasticsearch.yml):
````
cluster.name: es-dev-database
node.name: es-node-1 
network.host: 33.33.33.10
````

You can test if ElasticSearch is running/responding by issuing the following command:

```shell script
curl 'http://33.33.33.10:9200/?pretty'
```

##### Some common commands:

Check overall health of the elasticsearch cluster:
```shell script
curl -X GET 'http://33.33.33.10:9200/_cluster/health?pretty'
```

Get status of all indicies:
```shell script
curl -X GET 'http://33.33.33.10:9200/_all/_stats?pretty'
```

Get stats about individual nodes (for more detailed debugging/info):
```shell script
curl -X GET 'http://33.33.33.10:9200/_nodes/stats?pretty'
```

## Issues with VirtualBox install on Mac OS High Sierra

Could be related to a new `kext` security feature, so

- Go to `System Preferences` `Security & Privacy` `General`
- Set `Allow apps downloaded from App Store and identified developers`
- Run the script below
- Reinstall VirtualBox

```
#!/bin/bash

unload() {
        if [ `ps -ef | grep -c VirtualBox$` -ne 0 ]
        then
                echo "VirtualBox still seems to be running. Please investigate!!"
                exit 1;
        elif [ `ps -ef | grep -c [V]ir` -gt 0 ]
        then
                echo "Stopping running processes before unloading Kernel Extensions"
                ps -ef | grep [V]ir | awk '{print $2}' | xargs kill
        fi
        echo "Unloading Kernel Extensions"
        kextstat | grep "org.virtualbox.kext.VBoxUSB" > /dev/null 2>&1 && sudo kextunload -b org.virtualbox.kext.VBoxUSB
        kextstat | grep "org.virtualbox.kext.VBoxNetFlt" > /dev/null 2>&1 && sudo kextunload -b org.virtualbox.kext.VBoxNetFlt
        kextstat | grep "org.virtualbox.kext.VBoxNetAdp" > /dev/null 2>&1 && sudo kextunload -b org.virtualbox.kext.VBoxNetAdp
        kextstat | grep "org.virtualbox.kext.VBoxDrv" > /dev/null 2>&1 && sudo kextunload -b org.virtualbox.kext.VBoxDrv
}

load() {
        echo "Loading Kernel Extentions"
        sudo kextload "/Library/Application Support/VirtualBox/VBoxDrv.kext" -r "/Library/Application Support/VirtualBox/"
        sudo kextload "/Library/Application Support/VirtualBox/VBoxNetAdp.kext" -r "/Library/Application Support/VirtualBox/"
        sudo kextload "/Library/Application Support/VirtualBox/VBoxNetFlt.kext" -r "/Library/Application Support/VirtualBox/"
        sudo kextload "/Library/Application Support/VirtualBox/VBoxUSB.kext" -r "/Library/Application Support/VirtualBox/"
}

case "$1" in
        unload|remove)
                unload
                ;;
        load)
                load
                ;;
        *|reload)
                unload
                load
                ;;
esac

```

Or, if the error is about a user id mismatch, change the value in the file `./.vagrant/machines/default/virtualbox/creator_id`.



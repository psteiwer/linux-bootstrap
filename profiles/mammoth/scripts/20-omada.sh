#!/usr/bin/env bash
set -euo pipefail

cd /tmp
wget https://repo.mongodb.org/apt/ubuntu/dists/focal/mongodb-org/4.4/multiverse/binary-arm64/mongodb-org-server_4.4.18_arm64.deb
sudo apt install /tmp/mongodb-org-server_4.4.18_arm64.deb
apt list curl
sudo apt install openjdk-21-jdk-headless
sudo apt install jsvc
sudo update-alternatives --config java
cd /tmp/
wget https://static.tp-link.com/upload/software/2024/202411/20241101/Omada_SDN_Controller_v5.14.32.3_linux_x64.deb
sudo apt install /tmp/Omada_SDN_Controller_v5.14.32.3_linux_x64.deb


#AFTER UPDATE:
#/usr/bin/mongod --dbpath /opt/tplink/EAPController/data --repair
#!/bin/bash

# Uninstall previous Docker versions
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove -y $pkg; done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install Docker Engine
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Make project directories
mkdir baseproject && cd baseproject
mkdir esk && mkdir fleet && mkdir certs && mkdir data
cd data && mkdir es01data && mkdir kibanadata

cd ../esk
wget https://raw.githubusercontent.com/epikritis/detection-engineering-de-stuff/main/esk-es-kibana-docker-compose.yml -O docker-compose.yml
wget https://raw.githubusercontent.com/epikritis/detection-engineering-de-stuff/main/esk-es-kibana.env -O .env

cd ../fleet
wget https://raw.githubusercontent.com/epikritis/detection-engineering-de-stuff/main/fleet-docker-compose.yml -O docker-compose.yml
wget https://raw.githubusercontent.com/epikritis/detection-engineering-de-stuff/main/fleet.env -O .env

exit 0




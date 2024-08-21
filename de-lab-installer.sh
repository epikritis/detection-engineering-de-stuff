#!/bin/bash

# Memory configuration
sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf

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
cd ..

# Download the Docker Compose YAML and environment files for ESK
cd esk
wget https://raw.githubusercontent.com/epikritis/detection-engineering-de-stuff/main/esk-es-kibana-docker-compose.yml -O docker-compose.yml
wget https://raw.githubusercontent.com/epikritis/detection-engineering-de-stuff/main/esk-es-kibana.env -O .env

# Download the Docker Compose YAML and environment files for Fleet
cd ../fleet
wget https://raw.githubusercontent.com/epikritis/detection-engineering-de-stuff/main/fleet-docker-compose.yml -O docker-compose.yml
wget https://raw.githubusercontent.com/epikritis/detection-engineering-de-stuff/main/fleet.env -O .env

cd ..

exit 0

# If you opt for cloning the repository, the steps are as follows (after making the directories):
# [Uncomment the lines below, and your working directory should be `baseproject`.]
# git clone https://github.com/epikritis/detection-engineering-de-stuff.git
# cp detection-engineering-de-stuff/esk-es-kibana-docker-compose.yml esk/docker-compose.yml
# cp detection-engineering-de-stuff/esk-es-kibana.env esk/.env
# cp detection-engineering-de-stuff/fleet-docker-compose.yml fleet/docker-compose.yml
# cp detection-engineering-de-stuff/fleet.env fleet/.env



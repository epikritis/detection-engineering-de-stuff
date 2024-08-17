# DE LAB SETUP ON UBUNTU SERVER

## System requirements

4 vCPU, 8 GB RAM, 128 GB VM-attached storage

## Steps

1. Download Docker: https://docs.docker.com/desktop/install/linux-install/
2. Adjust memory requirements:

```
sudo sysctl -w vm.max_map_count=262144
Modify /etc/sysctl.conf and add entry 'vm.max_map_count=262144'.
```

3. Make directories as follows:

```
mkdir baseproject && cd baseproject
mkdir esk && mkdir fleet && mkdir certs && mkdir data
cd data && mkdir es01data && mkdir kibanadata
```

4. Create docker-compose.yml and .env files using the scripts below:

##### ES, Kibana Docker Compose YAML (goes into esk dir)

```
version: "3.9"

services:
  setup:
    image: docker.elastic.co/elasticsearch/elasticsearch:${STACK_VERSION}
    volumes:
      - ../certs:/usr/share/elasticsearch/config/certs
    user: "0"
    command: >
      bash -c '
        if [ x${ELASTIC_PASSWORD} == x ]; then
          echo "Set the ELASTIC_PASSWORD environment variable in the .env file";
          exit 1;
        elif [ x${KIBANA_PASSWORD} == x ]; then
          echo "Set the KIBANA_PASSWORD environment variable in the .env file";
          exit 1;
        fi;
        if [ ! -f config/certs/ca.zip ]; then
          echo "Creating CA";
          bin/elasticsearch-certutil ca --silent --pem -out config/certs/ca.zip;
          unzip config/certs/ca.zip -d config/certs;
        fi;
        if [ ! -f config/certs/certs.zip ]; then
          echo "Creating certs";
          echo -ne \
          "instances:\n"\
          "  - name: es01\n"\
          "    dns:\n"\
          "      - es01\n"\
          "      - localhost\n"\
          "    ip:\n"\
          "      - 127.0.0.1\n"\
          "  - name: es02\n"\
          "    dns:\n"\
          "      - es02\n"\
          "      - localhost\n"\
          "    ip:\n"\
          "      - 127.0.0.1\n"\
          > config/certs/instances.yml;
          bin/elasticsearch-certutil cert --silent --pem -out config/certs/certs.zip --in config/certs/instances.yml --ca-cert config/certs/ca/ca.crt --ca-key config/certs/ca/ca.key;
          unzip config/certs/certs.zip -d config/certs;
        fi;
        echo "Setting file permissions"
        chown -R root:root config/certs;
        find . -type d -exec chmod 750 \{\} \;;
        find . -type f -exec chmod 640 \{\} \;;
        echo "Waiting for Elasticsearch availability";
        until curl -s --cacert config/certs/ca/ca.crt https://es01:9200 | grep -q "missing authentication credentials"; do sleep 30; done;
        echo "Setting kibana_system password";
        until curl -s -X POST --cacert config/certs/ca/ca.crt -u elastic:${ELASTIC_PASSWORD} -H "Content-Type: application/json" https://es01:9200/_security/user/kibana_system/_password -d "{\"password\">
        echo "All done!";
      '
    healthcheck:
      test: ["CMD-SHELL", "[ -f config/certs/es01/es01.crt ]"]
      interval: 1s
      timeout: 5s
      retries: 120

  es01:
    depends_on:
      setup:
        condition: service_healthy
    image: docker.elastic.co/elasticsearch/elasticsearch:${STACK_VERSION}
    volumes:
      - ../certs:/usr/share/elasticsearch/config/certs
      - ${ES1_DATA}:/usr/share/elasticsearch/data1
    ports:
      - ${ES_PORT}:9200
    environment:
      - node.name=es01
      - cluster.name=${CLUSTER_NAME}
      - cluster.initial_master_nodes=es01 #,es02
 #     - discovery.seed_hosts=es02
      - ELASTIC_PASSWORD=${ELASTIC_PASSWORD}
      - bootstrap.memory_lock=true
      - xpack.security.enabled=true
      - xpack.security.http.ssl.enabled=true
      - xpack.security.http.ssl.key=certs/es01/es01.key
      - xpack.security.http.ssl.certificate=certs/es01/es01.crt
      - xpack.security.http.ssl.certificate_authorities=certs/ca/ca.crt
      - xpack.security.http.ssl.verification_mode=certificate
      - xpack.security.transport.ssl.enabled=true
      - xpack.security.transport.ssl.key=certs/es01/es01.key
      - xpack.security.transport.ssl.certificate=certs/es01/es01.crt
      - xpack.security.transport.ssl.certificate_authorities=certs/ca/ca.crt
      - xpack.security.transport.ssl.verification_mode=certificate
      - xpack.license.self_generated.type=${LICENSE}
    mem_limit: ${ES_MEM_LIMIT}
    ulimits:
      memlock:
        soft: -1
        hard: -1
    healthcheck:
      test:
        [
          "CMD-SHELL",
          "curl -s --cacert config/certs/ca/ca.crt https://localhost:9200 | grep -q 'missing authentication credentials'",
        ]
      interval: 10s
      timeout: 10s
      retries: 120

#  es02:
#    depends_on:
#      - es01
#    image: docker.elastic.co/elasticsearch/elasticsearch:${STACK_VERSION}
#    volumes:
#      - ../certs:/usr/share/elasticsearch/config/certs
#      - ${ES2_DATA}:/usr/share/elasticsearch/data2
#    environment:
#      - node.name=es02
#      - cluster.name=${CLUSTER_NAME}
#      - cluster.initial_master_nodes=es01,es02
#      - discovery.seed_hosts=es01
#      - bootstrap.memory_lock=true
#      - xpack.security.enabled=true
#      - xpack.security.http.ssl.enabled=true
#      - xpack.security.http.ssl.key=certs/es02/es02.key
#      - xpack.security.http.ssl.certificate=certs/es02/es02.crt
#      - xpack.security.http.ssl.certificate_authorities=certs/ca/ca.crt
#      - xpack.security.http.ssl.verification_mode=certificate
#      - xpack.security.transport.ssl.enabled=true
#      - xpack.security.transport.ssl.key=certs/es02/es02.key
#      - xpack.security.transport.ssl.certificate=certs/es02/es02.crt
#      - xpack.security.transport.ssl.certificate_authorities=certs/ca/ca.crt
#      - xpack.security.transport.ssl.verification_mode=certificate
#      - xpack.license.self_generated.type=${LICENSE}
#    mem_limit: ${MEM_LIMIT}
#    ulimits:
#      memlock:
#        soft: -1
#        hard: -1
#    healthcheck:
#      test:
#        [
#          "CMD-SHELL",
#          "curl -s --cacert config/certs/ca/ca.crt https://localhost:9200 | grep -q 'missing authentication credentials'",
#        ]
#      interval: 10s
#      timeout: 10s
#      retries: 120

  kibana:
    depends_on:
      es01:
        condition: service_healthy
#      es02:
#        condition: service_healthy
    image: docker.elastic.co/kibana/kibana:${STACK_VERSION}
    volumes:
      - ../certs:/usr/share/kibana/config/certs
      - ${KIBANA_DATA}:/usr/share/kibana/data
    ports:
      - ${KIBANA_PORT}:5601
    environment:
      - SERVERNAME=kibana
      - ELASTICSEARCH_HOSTS=https://es01:9200
      - ELASTICSEARCH_USERNAME=kibana_system
      - ELASTICSEARCH_PASSWORD=${KIBANA_PASSWORD}
      - ELASTICSEARCH_SSL_CERTIFICATEAUTHORITIES=config/certs/ca/ca.crt
      - XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY=${XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY}
      - XPACK_SECURITY_ENCRYPTIONKEY=${XPACK_SECURITY_ENCRYPTIONKEY}
      - XPACK_REPORTING_ENCRYPTIONKEY=${XPACK_REPORTING_ENCRYPTIONKEY}
    mem_limit: ${MEM_LIMIT}
    healthcheck:
      test:
        [
          "CMD-SHELL",
          "curl -s -I http://localhost:5601 | grep -q 'HTTP/1.1 302 Found'",
        ]
      interval: 10s
      timeout: 10s
      retries: 120

networks:
  default:
    name: elastic-stack-network

volumes:
  certs:
    driver: local
  esdata01:
    driver: local
  esdata02:
    driver: local
  kibanadata:
    driver: local
```

##### ES, Kibana .env file (goes into esk dir)

```
ELASTIC_PASSWORD=<generate secure password>
KIBANA_PASSWORD=<generate secure password>
STACK_VERSION=8.15.0
CLUSTER_NAME=docker-cluster
LICENSE=basic
ES_PORT=9200
KIBANA_PORT=5601
MEM_LIMIT=1073741824
ES_MEM_LIMIT=2147483648
XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY=<generate secure token>
XPACK_SECURITY_ENCRYPTIONKEY=<generate secure token>
XPACK_REPORTING_ENCRYPTIONKEY=<generate secure token>
ES1_DATA=/home/wilber/baseproject/data/es01data
#ES2_DATA=/home/wilber/baseproject/data/es02data
KIBANA_DATA=/home/wilber/baseproject/data/kibanadata
```

##### Fleet Docker Compose YAML (goes into fleet dir)

```
version: "3.9"
services:
  fleet-server:
    image: docker.elastic.co/beats/elastic-agent:${STACK_VERSION}
    container_name: fleet-server
    restart: always
    volumes:
      - ../certs:/certs
    ports:
      - ${FLEET_PORT}:8220
    user: root
    environment:
      - FLEET_SERVER_ENABLE=true
      - FLEET_SERVER_POLICY_NAME=fleet-server-policy
      - FLEET_SERVER_ELASTICSEARCH_HOST=https://es01:9200
      - FLEET_SERVER_SERVICE_TOKEN=${FLEET_SERVER_SERVICE_TOKEN}
      - FLEET_SERVER_ELASTICSEARCH_CA=/certs/ca/ca.crt
      - FLEET_INSECURE=true
    mem_limit: ${MEM_LIMIT}

networks:
  default:
    name: elastic-stack-network
```

##### Fleet .env file (goes into fleet dir)

```
STACK_VERSION=8.15.0
FLEET_PORT=8220
MEM_LIMIT=1073741824
FLEET_SERVER_SERVICE_TOKEN=<copy token from Kibana dashboard>
```

5. Spin up ESK container:

```
sudo docker compose up -d
```

6. Login to Kibana using the elastic password generated.

7. Fleet server details:

- Fleet server IP: https://host_ip:8220
- On Settings tab, Elasticsearch IP: https://host_ip:9200
- On Settings tab, under Advanced YAML configuration, enter 'ssl.verification_mode: none'.

8. Spin up Fleet container.

9. Remember to allow ports 9200, 9300 (if you have more than one ES node), 5601, 8220 on firewall.

10. Create test VM(s): Windows, Linux, etc. (or even K8s)...

- These will generate telemetry for which we'll create detection rules.
- During Elastic agent installation, use Fleet server option.
- Install agent using root or admin privileges.
- Append '--insecure' option at the end of the install command.

11. Switch off containers safely by using `sudo docker stop <container_name>`.

- Start with fleet-server, then esk-kibana-1, then esk-es01-1.
- When restarting the containers, follow the reverse order, i.e. ES then Kibana then Fleet.

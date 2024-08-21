# DE LAB SETUP ON UBUNTU SERVER

## System requirements

Recommended for optimal performance: 4 vCPU, 8 GB RAM
For storage, minimum required should be ~30 GB. Please keep in mind that you require more than that to store your endpoint-generated logs.

## Steps

1. Download and run `de-lab-installer.sh`.

2. Modify the .env file in the esk directory by adding your passwprds.

==Note that this is not good practice, and *NEVER* hardcode secrets in a production environment. Consider using a secrets manager or a key vault.==

3. Cd to the esk directory and spin up the Elasticsearch and Kibana containers:

```
sudo docker compose up -d
```

Confirm the containers are up and running using the command `sudo docker compose ps -a`.

4. Login to Kibana using the `ELASTIC_PASSWORD` generated.

5. On the Kibana dashboard, navigate to *Management* > *Fleet*  and add a Fleet server:

- Fleet server IP: https://host_publicIP:8220
- Once you click on continue, copy the generated `fleet-server-service-token` to the .env file in the fleet directory.

6. Cd to the fleet directory and spin up the Fleet container.

7. On the Kibana dashboard, navigate to *Management* > *Fleet*  and modify the following Fleet server details:

- On the Settings tab, Elasticsearch IP: https://host_publicIP:9200
- On the Settings tab, under Advanced YAML configuration, enter 'ssl.verification_mode: none'.

*Remember to allow ports 9200, 9300 (if you have more than one ES node), 5601, 8220 on firewall.*

## Additional Steps to Make the Lab Complete

Create test VM(s): Windows, Linux, etc. (or even K8s)...

- These will generate telemetry for which we'll create detection rules.
- During Elastic agent installation, use Fleet server option.
- Install agent using root or admin privileges.
- Append `--insecure` option at the end of the `install` command.

## Container Management Tips

Switch off containers safely by using `sudo docker stop <container_name>`.

- Begin with fleet-server, then esk-kibana-1, then esk-es01-1.
- When restarting the containers, follow the reverse order, i.e. ES then Kibana then Fleet.
- To confirm that each container is up, do as follows:
  - For ES, log in to https://host_publicIP:9200 using the user `elastic` and password set in the file `/esk/.env`.
  - For Kibana, the URL is http://host_publicIP:5601 with the same credentials ^.
  - For the Fleet container, you can check its health status in Kibana.

> Live document: Updates may be added with time.
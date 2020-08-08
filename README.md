# parsedmarc-dockerized
**NOT FOR PRODUCTIVE USE**

To setup:
```
$ cd /opt/
$ git clone https://github.com/patschi/parsedmarc-dockerzied.git
# Edit docker-compose.yml and change environment variables below for geoipupdate from maxmind.
# Edit data/conf/parsedmarc/config.ini for parsedmarc itself (and change test to False when tested!)
$ docker-compose pull
$ docker-compose up -d
```

Then the whole stack is being built, created, started and the corresponding dashboard automatically imported into Kibana. After a while you can access the Kibana dashboard with parsed information by [parsedmarc](https://github.com/domainaware/checkdmarc) under the reverse proxy with an automatically self-signed certificate at `https://IP:9999`.

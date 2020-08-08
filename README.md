# parsedmarc-dockerized

Note: The standalone `parsedmarc` docker image can also be used, if interested: [hub.docker.com/r/patschi/parsedmarc](https://hub.docker.com/r/patschi/parsedmarc).

## Setup:
```
$ cd /opt/
$ git clone https://github.com/patschi/parsedmarc-dockerized.git
$ cd parsedmarc-dockerized/
$ nano docker-compose.yml # Edit docker-compose.yml and change environment variables below for geoipupdate from maxmind.
$ nano data/conf/parsedmarc/config.ini # Edit parsedmarc config file (and change test to False when testing done!)
$ docker-compose up -d
```

### What's happening then?

1. First, the whole stack is being created and started.
2. During the startup of the "init" container, all required steps are being taken care of - like generating a self-signed certificate for the webserver.
3. Once kibana container is started up, the corresponding parsedmarc dashboard is automatically imported into Kibana.
4. After a while you can access the Kibana dashboard under the shipped reverse proxy with at `https://IP:9999`.

## Credits

Built on top of the awesome [parsedmarc](https://github.com/domainaware/checkdmarc), [Elasticsearch and Kibana](https://www.elastic.co/), [nginx](https://nginx.org), [Docker](https://docker.com) and using [MaxMind GeoIP](https://dev.maxmind.com/geoip/geoip2/geolite2/).

# parsedmarc-dockerized

Note: The standalone `parsedmarc` docker image on [DockerHub @ patschi/parsedmarc](https://hub.docker.com/r/patschi/parsedmarc) can also be used, if interested.

## Setup:
1. Get basics together:
```
git clone https://github.com/patschi/parsedmarc-dockerized.git /opt/parsedmarc-dockerized/
cd /opt/parsedmarc-dockerized/ && cp data/conf/parsedmarc/config.sample.ini data/conf/parsedmarc/config.ini
```

2. Now we create an environment file for your geoipupdate settings from your [MaxMind account](https://www.maxmind.com/en/account/). For update cycles see [here](https://support.maxmind.com/geoip-faq/geoip2-and-geoip-legacy-database-updates/how-often-are-the-geoip2-and-geoip-legacy-databases-updated/). (Fill in your data!)
```
cat > geoipupdate.env <<EOF
GEOIPUPDATE_ACCOUNT_ID=HERE_GOES_YOUR_ACCOUNT_ID
GEOIPUPDATE_LICENSE_KEY=HERE_GOES_YOUR_LICENSE_KEY
GEOIPUPDATE_FREQUENCY=24
EOF
```

3. Next we change the `parsedmarc` config (see [docs](https://domainaware.github.io/parsedmarc/#configuration-file), and change `Test` to `False` when proper testing done)
```
nano data/conf/parsedmarc/config.ini
```

4. Finally, we start up the stack:
```
docker-compose up -d
```

### What's happening then?

1. First, the whole stack is being created and started.
2. During the startup of the "init" container, all required steps are being taken care of - like generating a self-signed certificate for the webserver.
3. Once kibana container is started up, the corresponding parsedmarc dashboard is automatically imported into Kibana.
4. After a while you can access the Kibana dashboard under the shipped reverse proxy with at `https://HOST_IP:9999`.

## Credits

Built on top of the awesome [parsedmarc](https://github.com/domainaware/checkdmarc), [Elasticsearch and Kibana](https://www.elastic.co/), [nginx](https://nginx.org), [Docker](https://docker.com) and using [MaxMind GeoIP](https://dev.maxmind.com/geoip/geoip2/geolite2/).

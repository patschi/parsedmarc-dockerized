# parsedmarc-dockerized

Note: The standalone `parsedmarc` docker image on [DockerHub @ patschi/parsedmarc](https://hub.docker.com/r/patschi/parsedmarc) can also be used, if interested.


## Setup:
1. Get basics together:
```
git clone https://github.com/patschi/parsedmarc-dockerized.git /opt/parsedmarc-dockerized/
cd /opt/parsedmarc-dockerized/ && cp data/conf/parsedmarc/config.sample.ini data/conf/parsedmarc/config.ini
```

2. Next we change the `parsedmarc` config (see [docs](https://domainaware.github.io/parsedmarc/#configuration-file). You can set `Test` to `True` for testing purposes.)
```
nano data/conf/parsedmarc/config.ini
```

3. Now we create an environment file, containing your geoipupdate settings from your [MaxMind account](https://www.maxmind.com/en/account/) to allow the container to pull the databases. For update cycles of the databases, please see [here](https://support.maxmind.com/geoip-faq/geoip2-and-geoip-legacy-database-updates/how-often-are-the-geoip2-and-geoip-legacy-databases-updated/). (Fill in your data!)
```
cat > geoipupdate.env <<EOF
GEOIPUPDATE_ACCOUNT_ID=HERE_GOES_YOUR_ACCOUNT_ID
GEOIPUPDATE_LICENSE_KEY=HERE_GOES_YOUR_LICENSE_KEY
GEOIPUPDATE_FREQUENCY=24
EOF
```

4. Finally, we start up the stack and wait:
```
docker-compose up -d
```

### What's happening then?

1. First, containers of the stack are created and started. This might take a while, as several containers have dependencies on others being in a healthy state (meaning that its service must be fully started).
2. During the startup of the `parsedmarc-init` container, all required steps and preparations are being taken care of - like generating a self-signed certificate for the included `nginx` webserver.
3. Once the Kibana container - where you can view the dashboards - is started up, the corresponding parsedmarc dashboards are automatically imported into Kibana by the `parsedmarc-init` container.
4. After some while, when everything is up and running, you can then access Kibana and its dashboards under the shipped reverse proxy at `https://HOST_IP:9999`. (Make sure to use HTTPS!)


## Port configuration
You can optionally add a `.env` file with the `PORT_BINDING` parameter to configure where `parsedmarc-dockerized` should be listening for connections.

Format: `[address:]port:443` (`address` is optional. `443` MUST NOT be changed)  
Additional information: https://docs.docker.com/engine/reference/commandline/run/#publish-or-expose-port--p---expose

**Examples:**
```.env
# default, does not need to be specified explicitly
PORT_BINDING=9999:443

# change listenting port to 8888
PORT_BINDING=8888:443

# don't expose it to the internet, only listen on the host itself
PORT_BINDING=127.0.0.1:9999:443
```

By default `parsedmarc-dockerized` is listening at port `9999` on all interfaces.

If you're running `parsedmarc-dockerized` on a server without a firewall it's freely accessible over the internet by everyone. If you want it to only listen on the host itself you can set it to `127.0.0.1:9999:443`

You can then use an SSH tunnel to make it accessible on your local machine. On Linux and macOS this works with the command `ssh -NL 9999:127.0.0.1:9999 USER@HOST` (make sure to set `USER@HOST` for your server). If the SSH tunnel was successfully established you can access Kibana and its dashboards on your local machine via `https://localhost:9999`. (Make sure to use HTTPS!).



## Credits

Built with awesome [parsedmarc](https://github.com/domainaware/checkdmarc), [Elasticsearch and Kibana](https://www.elastic.co/), [nginx](https://nginx.org), [Docker](https://docker.com) and [MaxMind GeoIP](https://dev.maxmind.com/geoip/geoip2/geolite2/).

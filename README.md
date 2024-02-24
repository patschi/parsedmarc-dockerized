# parsedmarc-dockerized

## Description

This project's purpose providing an easy way deploying [parsedmarc](https://github.com/domainaware/parsedmarc) in your environment. It has built docker images ready to use, including a small init container to configure some things for you. For any inquries regarding parsedmarc itself, please see mentioned GitHub link of the main project.

**Note**: The standalone `parsedmarc` docker image on [DockerHub @ patschi/parsedmarc](https://hub.docker.com/r/patschi/parsedmarc) can also be used standalone and independently, should there be any interest.

## Setup

1. Prepare the basics:

    ```bash
    git clone https://github.com/patschi/parsedmarc-dockerized.git /opt/parsedmarc-dockerized/
    cp /opt/parsedmarc-dockerized/data/conf/parsedmarc/config.sample.ini /opt/parsedmarc-dockerized/data/conf/parsedmarc/config.ini
    ```

    If needed, Docker might need to be installed. On Debian/Ubuntu, as following:

    ```bash
    curl -sSL https://get.docker.com/ | CHANNEL=stable sh
    systemctl enable --now docker
    apt install docker-compose-plugin
    ```

2. Next we change the `parsedmarc` config (please make sure to [read the parsedmarc documentation throughly](https://domainaware.github.io/parsedmarc/#configuration-file)). Adjust settings to your needs. (You can set `Test` to `True` for testing purposes.)

    ```bash
    nano /opt/parsedmarc-dockerized/data/conf/parsedmarc/config.ini
    ```

    **Important note**: This project's purpose is NOT to manage this configuration file for you. Should defaults change of the parsedmarc project, you must change the configuration file yourself.

3. Now, we create an environment file containing the geoipupdate settings from your [MaxMind account](https://www.maxmind.com/en/account/). This allows the respective container to pull the geolocation databases automatically. For update cycles of the databases, please see [here](https://support.maxmind.com/geoip-faq/geoip2-and-geoip-legacy-database-updates/how-often-are-the-geoip2-and-geoip-legacy-databases-updated/). (Fill in your account details!)

    ```bash
    cat > /opt/parsedmarc-dockerized/geoipupdate.env <<EOF
    GEOIPUPDATE_ACCOUNT_ID=HERE_GOES_YOUR_ACCOUNT_ID
    GEOIPUPDATE_LICENSE_KEY=HERE_GOES_YOUR_LICENSE_KEY
    GEOIPUPDATE_FREQUENCY=24
    EOF
    ```

4. Finally, we start up the stack and wait:

    ```bash
    cd /opt/parsedmarc-dockerized/
    docker compose up -d
    ```

    **Note**: Depending on your setup, the startup might take couple of minutes - especially the more resource-intensive applications elasticsearch and kibana.

### What's happening then?

Magic.

However, should you still want more details:

1. First, containers of the stack are created and started. This might take a while, as several containers have dependencies on others being in a healthy state (meaning that its service must be fully up and running before proceeding).
2. During the startup of the `parsedmarc-init` container, all required steps and preparations are being taken care of - like generating a self-signed certificate for the included `nginx` webserver.
3. Once the Kibana container - where you can view the dashboards - is running, the corresponding parsedmarc dashboards are automatically imported into Kibana from the `parsedmarc-init` container.
4. After some while, when everything is up and running, you can then access Kibana and its dashboards under the shipped reverse proxy at `https://HOST_IP:9999`. (Make sure to use HTTPS!)

**Note:** It is recommended to use some reverse proxy in front of this docker stack, should you want to have parsedmarc exposed externally. Also SSL termination and any authentication should be done externally.

## Configuration

### Port configuration

Optionally, you can add a `.env` file with the `PORT_BINDING` parameter to configure on which port the reverse proxy is listening for incoming HTTPS connections.

Format: `[address:]port:443` (`address` is optional. `443` MUST NOT be changed)  
Additional information: [docs.docker.com/engine/reference/commandline/run/#publish-or-expose-port--p---expose](https://docs.docker.com/engine/reference/commandline/run/#publish-or-expose-port--p---expose)

**Examples:**

```bash
# this is the current default if nothing specified
PORT_BINDING=9999:443

# change listening port to 8888
PORT_BINDING=8888:443

# don't expose it to the internet, only listen on the host itself
PORT_BINDING=127.0.0.1:9999:443
```

By default `parsedmarc-dockerized` is listening at port `9999` on all interfaces.

If you're running `parsedmarc-dockerized` on a server without a firewall it's freely accessible over the internet by everyone. If you want it to only listen on the host itself, you can use the example above.

You can then use an SSH tunnel to make it accessible on your local machine. On Linux and macOS this works with the command `ssh -NL 9999:127.0.0.1:9999 USER@HOST` (make sure to set `USER@HOST` for your server). If the SSH tunnel was successfully established you can access Kibana and its dashboards on your local machine via `https://localhost:9999`. (Make sure to use HTTPS!).

## Credits

Built with awesome [parsedmarc](https://github.com/domainaware/parsedmarc), [Elasticsearch and Kibana](https://www.elastic.co/), [nginx](https://nginx.org), [Docker](https://docker.com) and [MaxMind GeoIP](https://dev.maxmind.com/geoip/geoip2/geolite2/). Together with [awesome contributors](https://github.com/patschi/parsedmarc-dockerized/graphs/contributors) in this project.

## Troubleshooting

### Error 'No matching indices found: No indices match pattern "dmarc_aggregate*"' in Kibana dashboard

This typically means that no data has been imported by parsedmarc in elasticsearch yet. See [github.com/domainaware/parsedmarc/issues/268](https://github.com/domainaware/parsedmarc/issues/268) for reference. parsedmarc processes certain amount of emails (see `batch_size` in documentation) before saving the data to elasticsearch.

For example, debug logs from parsedmarc will indicate that indices will be only created upon saving a report to elasticsearch:

```text
    INFO:__init__.py:1019:Parsing mail from postmaster@example.com on 2020-09-19 23:04:13+00:00
    INFO:elastic.py:364:Saving aggregate report to Elasticsearch
   DEBUG:elastic.py:284:Creating Elasticsearch index: dmarc_aggregate-2020-09-17
```

### I am seeing 'Unrecognized layerType EMS_VECTOR_TILE'

There might have been changes to the dashboard view of parsedmarc, requiring new layer types older Kibana/Elasticsearch versions do not support.

**Fix:**
Update to Elasticsearch/Kibana 8.x.

FROM pypy:3-slim

COPY init-script.sh /start.sh
RUN apt-get update \
    && apt-get install -y --no-install-recommends libxslt-dev libz-dev libxml2-dev gcc libemail-outlook-message-perl curl openssl jq bash \
    && pip install --no-cache-dir -U parsedmarc \
    && apt-get purge --yes gcc && apt-get autoremove --yes && apt-get clean \
    && rm -Rf /var/lib/{apt,dpkg}/ && rm -Rf /root/.cache/ && rm -rf /var/lib/apt/lists/* \
    && chmod +x /start.sh 
ENTRYPOINT ["./start.sh"]
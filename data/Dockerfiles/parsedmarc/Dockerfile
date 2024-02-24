FROM pypy:3-slim

ADD start.sh /start.sh
RUN apt-get update \
    && apt-get install -y \
        python3-pip python3-dev libxml2-dev libxslt-dev libz-dev libxml2-dev \
        gcc libemail-outlook-message-perl python3-gi python3-gi-cairo \
        gir1.2-secret-1 \
    && pip install -U parsedmarc \
    && apt-get purge --yes gcc && apt autoremove --yes && apt-get clean \
    && rm -Rf /var/lib/{apt,dpkg}/ && rm -Rf /root/.cache/ \
    && chmod +x /start.sh

ENTRYPOINT [ "/start.sh" ]

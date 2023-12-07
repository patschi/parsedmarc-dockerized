FROM pypy:3-slim

ADD start.sh /start.sh
RUN apt-get update \
    && apt-get install -y libxslt-dev libz-dev libxml2-dev gcc libemail-outlook-message-perl \
    && pip install -U parsedmarc \
    && apt-get purge --yes gcc && apt autoremove --yes && apt-get clean \
    && rm -Rf /var/lib/{apt,dpkg}/ && rm -Rf /root/.cache/ \
    && chmod +x /start.sh

ENTRYPOINT [ "/start.sh" ]

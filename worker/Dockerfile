FROM panosru/php:latest

RUN yes '' | apt-get install netcat gettext-base unzip

# Clean up
RUN apt-get autoremove -y --purge \
    && apt-get clean \
    && rm -Rf /tmp/*

WORKDIR /var/www

ENV PHPCENSOR_VERSION=0.24.0

COPY entrypoint.sh /entrypoint.sh
COPY config.tmpl.yml /config.tmpl.yml

ENTRYPOINT ["/entrypoint.sh"]

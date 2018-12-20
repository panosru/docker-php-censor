FROM registry.gitlab.com/panosru/docker/php:dev

RUN yes '' | apt-get install netcat gettext-base unzip

# Clean up
RUN apt-get autoremove -y --purge \
    && apt-get clean \
    && rm -Rf /tmp/*

WORKDIR /var/www

ENV PHPCENSOR_VERSION=0.24.0

RUN rm -rf ./html && \
    git clone -b $PHPCENSOR_VERSION --single-branch --depth 1 https://github.com/corpsee/php-censor.git . && \
    composer install

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

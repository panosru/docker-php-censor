Run `docker network create webservices` before `docker-compose up`

`registry.gitlab.com/panosru/docker/php:dev`

is:

```
#++++++++++++++++++++++++++++++++++++++
# PHP application Docker container
#++++++++++++++++++++++++++++++++++++++

FROM php:7.2.13-fpm


RUN apt-get update && apt-get upgrade -y \
    wget \
    git \
    unzip \
    g++ \
    librabbitmq-dev \
    libc-client-dev \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libkrb5-dev \
    libpq-dev \
    libmagickwand-dev \
    libyaml-dev \
    libmcrypt-dev \
    libpng-dev \
    libmemcached-dev \
    libssl-dev \
    libssl-doc \
    libsasl2-dev \
    zlib1g-dev \
    && docker-php-ext-install \
    bz2 \
    bcmath \
    calendar \
    exif \
    gettext \
    iconv \
    mbstring \
    pcntl \
    shmop \
    mysqli \
    sockets \
    opcache \
    wddx \
    pgsql \
    pdo_mysql \
    pdo_pgsql \
    soap \
    zip \
    && docker-php-ext-configure gd \
    --with-freetype-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && yes '' | pecl install imagick && docker-php-ext-enable imagick \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap \
    && pecl install memcached && docker-php-ext-enable memcached \
    && pecl install mongodb && docker-php-ext-enable mongodb \
    && pecl install redis && docker-php-ext-enable redis \
    && pecl install xdebug && docker-php-ext-enable xdebug \
    && pecl install igbinary && docker-php-ext-enable igbinary \
    && pecl install psr && docker-php-ext-enable psr \
    && pecl install mcrypt-1.0.1 && docker-php-ext-enable mcrypt \
    && pecl install amqp && docker-php-ext-enable amqp \
    && pecl install yaml && docker-php-ext-enable yaml

# Install APCu and APC backward compatibility
RUN pecl install apcu \
    && pecl install apcu_bc \
    && docker-php-ext-enable apcu --ini-name 10-docker-php-ext-apcu.ini \
    && docker-php-ext-enable apc --ini-name 20-docker-php-ext-apc.ini

# Install Phalcon
ENV PHALCON_VERSION=3.4.2

RUN curl -sSL "https://codeload.github.com/phalcon/cphalcon/tar.gz/v${PHALCON_VERSION}" | tar -xz \
    && cd cphalcon-${PHALCON_VERSION}/build \
    && ./install \
    && cp ../tests/_ci/phalcon.ini $(php-config --configure-options | grep -o "with-config-file-scan-dir=\([^ ]*\)" | awk -F'=' '{print $2}') \
    && cd ../../ \
    && rm -r cphalcon-${PHALCON_VERSION} \
    && docker-php-ext-enable phalcon

# Install Swoole
RUN git clone https://github.com/swoole/swoole-src.git && \
    cd swoole-src && \
    phpize && \
    ./configure && \
    make && make install && \
    cd ../ && \
    rm -r swoole-src && \
    docker-php-ext-enable swoole


# Install Blackfire
RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
    && mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini

# Install TA-Lib
RUN wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz && \
  tar -xvzf ta-lib-0.4.0-src.tar.gz && \
  cd ta-lib/ && \
  ./configure --prefix=/usr && \
  make && \
  make install

RUN rm -R ta-lib ta-lib-0.4.0-src.tar.gz

# Install Trader PHP Extension
RUN pecl install trader && docker-php-ext-enable trader

# Install Composer
RUN curl --silent --show-error https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && ln -s $(composer config --global home) /root/composer

ENV PATH $PATH:/root/composer/vendor/bin

# Clean up
RUN pecl clear-cache \
    && apt-get autoremove -y --purge \
    && apt-get clean \
    && rm -Rf /tmp/*
```

Use a `docker-compose.prod.yml` file, mine looks like this:

```
version: '3.7'

services:

  app:
    restart: always
    env_file:
      - ./env/prod/phpcensor.env

  web:
    restart: always
    env_file:
      - ./env/prod/web.env
      - ./env/prod/phpcensor.env
    environment:
      VIRTUAL_HOST: mydomain.com
      LETSENCRYPT_HOST: mydomain.com
      LETSENCRYPT_EMAIL: johndoe@domain.com

  worker:
    restart: always
    env_file:
      - ./env/prod/phpcensor.env

  db:
    restart: always
    env_file:
      - ./env/prod/database.pgsql.env

  queue:
    restart: always
```
I'm using nginx-proxy and in production env I start my containers with `docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d`

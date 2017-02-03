FROM php:7.0.15-fpm-alpine

MAINTAINER Alexey Boyko <ket4yiit@gmail.com>

WORKDIR /var/www/html

RUN docker-php-ext-install pdo pdo_mysql 

RUN apk update && \
    apk add git openssh gettext && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/bin/composer

RUN git clone https://github.com/corpsee/php-censor.git .
RUN composer install

ADD entrypoint.sh /
ADD config.tmpl.yml /

ENV DB_HOST=localhost
ENV DB_TYPE=mysql
ENV DB_NAME=phpcensor
ENV DB_USER=phpcensor
ENV DB_PASS=changethepass
ENV SITE_URL=http://phpcensor.local
ENV BEANSTALK_HOST=localhost
ENV BEANSTALK_QUEUE_NAME=phpcensor

ENTRYPOINT ["/entrypoint.sh"]
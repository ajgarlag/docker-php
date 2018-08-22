FROM ajgarlag/debian:jessie

RUN apt-get update \
    && apt-get install -y \
        php5-cli \
        php5-curl \
        php5-fpm \
        php5-xdebug \
        git \
        unzip \
    && rm -rf /var/lib/apt/lists/*

RUN sed -e 's/error_log = .*/error_log = \/dev\/stderr/g' \
        -i /etc/php5/fpm/php-fpm.conf
RUN sed -e 's/listen = .*/listen = 9000/g' \
        -i /etc/php5/fpm/pool.d/www.conf

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

ADD https://phar.io/releases/phive.phar /tmp/phive.phar
ADD https://phar.io/releases/phive.phar.asc /tmp/phive.phar.asc
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys 0x9D8A98B29B2D5D79 \
    && gpg --verify /tmp/phive.phar.asc /tmp/phive.phar \
    && rm /tmp/phive.phar.asc \
    && chmod +x /tmp/phive.phar \
    && mv /tmp/phive.phar /usr/local/bin/phive

COPY dev.ini /etc/php5/mods-available/dev.ini
RUN php5enmod dev

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 9000
CMD ["php5-fpm", "--nodaemonize", "--fpm-config", "/etc/php5/fpm/php-fpm.conf"]

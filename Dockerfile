FROM ajgarlag/debian:jessie

RUN apt-get update \
    && apt-get install -y \
        php5-cli \
        php5-fpm \
        php5-xdebug \
        git \
        unzip \
        # Extensions from PHP source
        php5-curl \
        php5-enchant \
        php5-gd \
        php5-gmp \
        php5-imap \
        php5-interbase \
        php5-intl \
        php5-ldap \
        php5-mcrypt \
        php5-mysql \
        php5-odbc \
        php5-pgsql \
        php5-pspell \
        php5-readline \
        php5-recode \
        php5-snmp \
        php5-sqlite \
        php5-sybase \
        php5-tidy \
        php5-xmlrpc \
        php5-xsl \
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
RUN gpg --no-tty --keyserver ipv4.pool.sks-keyservers.net --recv-keys 0x9D8A98B29B2D5D79 \
    && gpg --no-tty --verify /tmp/phive.phar.asc /tmp/phive.phar \
    && rm /tmp/phive.phar.asc \
    && chmod 755 /tmp/phive.phar \
    && mv /tmp/phive.phar /usr/local/bin/phive

COPY dev.ini /etc/php5/mods-available/dev.ini
RUN php5enmod dev
RUN php5dismod snmp

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 9000
CMD ["php5-fpm", "--nodaemonize", "--fpm-config", "/etc/php5/fpm/php-fpm.conf"]

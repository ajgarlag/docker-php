FROM ajgarlag/debian:stretch

RUN apt-get update \
    && apt-get install -y \
        php7.0-cli \
        php7.0-fpm \
        php7.0-xdebug \
        git \
        gpg \
        unzip \
        # Extensions from PHP source
        php7.0-bcmath \
        php7.0-bz2 \
        php7.0-curl \
        php7.0-dba \
        php7.0-enchant \
        php7.0-gd \
        php7.0-gmp \
        php7.0-imap \
        php7.0-interbase \
        php7.0-intl \
        php7.0-json \
        php7.0-ldap \
        php7.0-mbstring \
        php7.0-mcrypt \
        php7.0-mysql \
        php7.0-odbc \
        php7.0-opcache \
        php7.0-pgsql \
        php7.0-pspell \
        php7.0-readline \
        php7.0-recode \
        php7.0-snmp \
        php7.0-soap \
        php7.0-sqlite3 \
        php7.0-sybase \
        php7.0-tidy \
        php7.0-xml \
        php7.0-xmlrpc \
        php7.0-xsl \
        php7.0-zip \
    && rm -rf /var/lib/apt/lists/*

RUN sed -e 's/error_log = .*/error_log = \/dev\/stderr/g' \
        -i /etc/php/7.0/fpm/php-fpm.conf
RUN sed -e 's/listen = .*/listen = 9000/g' \
        -i /etc/php/7.0/fpm/pool.d/www.conf
RUN mkdir -p /run/php \
    && chown www-data:www-data /run/php

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

ADD https://phar.io/releases/phive.phar /tmp/phive.phar
ADD https://phar.io/releases/phive.phar.asc /tmp/phive.phar.asc
RUN gpg --no-tty --keyserver hkps://keys.openpgp.org --recv-keys 0x9D8A98B29B2D5D79 \
    && gpg --no-tty --verify /tmp/phive.phar.asc /tmp/phive.phar \
    && rm /tmp/phive.phar.asc \
    && chmod 755 /tmp/phive.phar \
    && mv /tmp/phive.phar /usr/local/bin/phive

COPY dev.ini /etc/php/7.0/mods-available/dev.ini
RUN phpenmod dev
RUN phpdismod snmp

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 9000
CMD ["php-fpm7.0", "--nodaemonize", "--fpm-config", "/etc/php/7.0/fpm/php-fpm.conf"]

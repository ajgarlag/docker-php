FROM ajgarlag/debian:bullseye

RUN apt-get update \
    && apt-get install -y \
        php7.4-cli \
        php7.4-fpm \
        php7.4-xdebug \
        git \
        gpg \
        unzip \
        # Extensions from PHP source
        php7.4-bcmath \
        php7.4-bz2 \
        php7.4-curl \
        php7.4-dba \
        php7.4-enchant \
        php7.4-gd \
        php7.4-gmp \
        php7.4-imap \
        php7.4-interbase \
        php7.4-intl \
        php7.4-json \
        php7.4-ldap \
        php7.4-mbstring \
        php7.4-mysql \
        php7.4-odbc \
        php7.4-opcache \
        php7.4-pgsql \
        php7.4-pspell \
        php7.4-readline \
        php7.4-snmp \
        php7.4-soap \
        php7.4-sqlite3 \
        php7.4-sybase \
        php7.4-tidy \
        php7.4-xml \
        php7.4-xmlrpc \
        php7.4-xsl \
        php7.4-zip \
    && rm -rf /var/lib/apt/lists/*

RUN sed -e 's/error_log = .*/error_log = \/dev\/stderr/g' \
        -i /etc/php/7.4/fpm/php-fpm.conf
RUN sed -e 's/listen = .*/listen = 9000/g' \
        -i /etc/php/7.4/fpm/pool.d/www.conf
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

COPY dev.ini /etc/php/7.4/mods-available/dev.ini
RUN phpenmod dev
RUN phpdismod snmp

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 9000
CMD ["php-fpm7.4", "--nodaemonize", "--fpm-config", "/etc/php/7.4/fpm/php-fpm.conf"]

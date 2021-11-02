FROM ajgarlag/debian:buster

RUN apt-get update \
    && apt-get install -y \
        php7.3-cli \
        php7.3-fpm \
        php7.3-xdebug \
        git \
        gpg \
        unzip \
        # Extensions from PHP source
        php7.3-bcmath \
        php7.3-bz2 \
        php7.3-curl \
        php7.3-dba \
        php7.3-enchant \
        php7.3-gd \
        php7.3-gmp \
        php7.3-imap \
        php7.3-interbase \
        php7.3-intl \
        php7.3-json \
        php7.3-ldap \
        php7.3-mbstring \
        php7.3-mysql \
        php7.3-odbc \
        php7.3-opcache \
        php7.3-pgsql \
        php7.3-pspell \
        php7.3-readline \
        php7.3-recode \
        php7.3-snmp \
        php7.3-soap \
        php7.3-sqlite3 \
        php7.3-sybase \
        php7.3-tidy \
        php7.3-xml \
        php7.3-xmlrpc \
        php7.3-xsl \
        php7.3-zip \
    && rm -rf /var/lib/apt/lists/*

RUN sed -e 's/error_log = .*/error_log = \/dev\/stderr/g' \
        -i /etc/php/7.3/fpm/php-fpm.conf
RUN sed -e 's/listen = .*/listen = 9000/g' \
        -i /etc/php/7.3/fpm/pool.d/www.conf
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

COPY dev.ini /etc/php/7.3/mods-available/dev.ini
RUN phpenmod dev
RUN phpdismod snmp

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 9000
CMD ["php-fpm7.3", "--nodaemonize", "--fpm-config", "/etc/php/7.3/fpm/php-fpm.conf"]

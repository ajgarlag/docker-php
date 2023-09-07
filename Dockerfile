FROM ajgarlag/debian:bookworm

RUN apt-get update \
    && apt-get install -y \
        php8.2-cli \
        php8.2-fpm \
        php8.2-xdebug \
        git \
        gpg \
        unzip \
        # Extensions from PHP source
        php8.2-bcmath \
        php8.2-bz2 \
        php8.2-curl \
        php8.2-dba \
        php8.2-enchant \
        php8.2-gd \
        php8.2-gmp \
        php8.2-imap \
        php8.2-interbase \
        php8.2-intl \
        php8.2-ldap \
        php8.2-mbstring \
        php8.2-mysql \
        php8.2-odbc \
        php8.2-opcache \
        php8.2-pgsql \
        php8.2-pspell \
        php8.2-readline \
        php8.2-snmp \
        php8.2-soap \
        php8.2-sqlite3 \
        php8.2-sybase \
        php8.2-tidy \
        php8.2-xml \
        php8.2-xmlrpc \
        php8.2-xsl \
        php8.2-zip \
    && rm -rf /var/lib/apt/lists/*

RUN sed -e 's/error_log = .*/error_log = \/dev\/stderr/g' \
        -i /etc/php/8.2/fpm/php-fpm.conf
RUN sed -e 's/listen = .*/listen = 9000/g' \
        -i /etc/php/8.2/fpm/pool.d/www.conf
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

COPY dev.ini /etc/php/8.2/mods-available/dev.ini
RUN phpenmod dev
RUN phpdismod snmp

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 9000
CMD ["php-fpm8.2", "--nodaemonize", "--fpm-config", "/etc/php/8.2/fpm/php-fpm.conf"]

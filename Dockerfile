FROM ajgarlag/debian:buster

ADD https://packages.sury.org/php/apt.gpg /etc/apt/trusted.gpg.d/php.gpg
RUN chmod 644 /etc/apt/trusted.gpg.d/php.gpg
RUN echo "deb https://packages.sury.org/php/ buster main" | tee /etc/apt/sources.list.d/php.list

RUN apt-get update \
    && apt-get install -y \
        php8.0-cli \
        php8.0-fpm \
        php8.0-xdebug \
        git \
        gpg \
        unzip \
        # Extensions from PHP source
        php8.0-bcmath \
        php8.0-bz2 \
        php8.0-curl \
        php8.0-dba \
        php8.0-enchant \
        php8.0-gd \
        php8.0-gmp \
        php8.0-imap \
        php8.0-interbase \
        php8.0-intl \
        php8.0-ldap \
        php8.0-mbstring \
        php8.0-mysql \
        php8.0-odbc \
        php8.0-opcache \
        php8.0-pgsql \
        php8.0-pspell \
        php8.0-readline \
        php8.0-snmp \
        php8.0-soap \
        php8.0-sqlite3 \
        php8.0-sybase \
        php8.0-tidy \
        php8.0-xml \
        php8.0-xsl \
        php8.0-zip \
    && rm -rf /var/lib/apt/lists/*

RUN sed -e 's/error_log = .*/error_log = \/dev\/stderr/g' \
        -i /etc/php/8.0/fpm/php-fpm.conf
RUN sed -e 's/listen = .*/listen = 9000/g' \
        -i /etc/php/8.0/fpm/pool.d/www.conf
RUN mkdir -p /run/php \
    && chown www-data:www-data /run/php

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

COPY dev.ini /etc/php/8.0/mods-available/dev.ini
RUN phpenmod dev
RUN phpdismod snmp

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 9000
CMD ["php-fpm8.0", "--nodaemonize", "--fpm-config", "/etc/php/8.0/fpm/php-fpm.conf"]

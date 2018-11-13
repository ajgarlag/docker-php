FROM ajgarlag/debian:stretch

ADD https://packages.sury.org/php/apt.gpg /etc/apt/trusted.gpg.d/php.gpg
RUN chmod 644 /etc/apt/trusted.gpg.d/php.gpg
RUN echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list

RUN apt-get update \
    && apt-get install -y \
        php7.2-cli \
        php7.2-fpm \
        php7.2-xdebug \
        git \
        gpg \
        unzip \
        # Extensions from PHP source
        php7.2-bcmath \
        php7.2-bz2 \
        php7.2-curl \
        php7.2-dba \
        php7.2-enchant \
        php7.2-gd \
        php7.2-gmp \
        php7.2-imap \
        php7.2-interbase \
        php7.2-intl \
        php7.2-json \
        php7.2-ldap \
        php7.2-mbstring \
        php7.2-mysql \
        php7.2-odbc \
        php7.2-opcache \
        php7.2-pgsql \
        php7.2-pspell \
        php7.2-readline \
        php7.2-recode \
        php7.2-snmp \
        php7.2-soap \
        php7.2-sqlite3 \
        php7.2-sybase \
        php7.2-tidy \
        php7.2-xml \
        php7.2-xmlrpc \
        php7.2-xsl \
        php7.2-zip \
    && rm -rf /var/lib/apt/lists/*

RUN sed -e 's/error_log = .*/error_log = \/dev\/stderr/g' \
        -i /etc/php/7.2/fpm/php-fpm.conf
RUN sed -e 's/listen = .*/listen = 9000/g' \
        -i /etc/php/7.2/fpm/pool.d/www.conf
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

COPY dev.ini /etc/php/7.2/mods-available/dev.ini
RUN phpenmod dev

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 9000
CMD ["php-fpm7.2", "--nodaemonize", "--fpm-config", "/etc/php/7.2/fpm/php-fpm.conf"]

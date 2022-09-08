FROM ajgarlag/debian:bullseye

ADD https://packages.sury.org/php/apt.gpg /etc/apt/trusted.gpg.d/php.gpg
RUN chmod 644 /etc/apt/trusted.gpg.d/php.gpg
RUN echo "deb https://packages.sury.org/php/ bullseye main" | tee /etc/apt/sources.list.d/php.list

RUN apt-get update \
    && apt-get install -y \
        php8.1-cli \
        php8.1-fpm \
        php8.1-xdebug \
        git \
        gpg \
        unzip \
        # Extensions from PHP source
        php8.1-bcmath \
        php8.1-bz2 \
        php8.1-curl \
        php8.1-dba \
        php8.1-enchant \
        php8.1-gd \
        php8.1-gmp \
        php8.1-imap \
        php8.1-interbase \
        php8.1-intl \
        php8.1-ldap \
        php8.1-mbstring \
        php8.1-mysql \
        php8.1-odbc \
        php8.1-opcache \
        php8.1-pgsql \
        php8.1-pspell \
        php8.1-readline \
        php8.1-snmp \
        php8.1-soap \
        php8.1-sqlite3 \
        php8.1-sybase \
        php8.1-tidy \
        php8.1-xml \
        php8.1-xsl \
        php8.1-zip \
    && rm -rf /var/lib/apt/lists/*

RUN sed -e 's/error_log = .*/error_log = \/dev\/stderr/g' \
        -i /etc/php/8.1/fpm/php-fpm.conf
RUN sed -e 's/listen = .*/listen = 9000/g' \
        -i /etc/php/8.1/fpm/pool.d/www.conf
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

COPY dev.ini /etc/php/8.1/mods-available/dev.ini
RUN phpenmod dev
RUN phpdismod snmp

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 9000
CMD ["php-fpm8.1", "--nodaemonize", "--fpm-config", "/etc/php/8.1/fpm/php-fpm.conf"]

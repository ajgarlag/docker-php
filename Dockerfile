FROM ajgarlag/debian:stretch

RUN apt-get update \
    && apt-get install -y \
        apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

ADD https://packages.sury.org/php/apt.gpg /etc/apt/trusted.gpg.d/php.gpg
RUN chmod 644 /etc/apt/trusted.gpg.d/php.gpg
RUN echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list

RUN apt-get update \
    && apt-get install -y \
        php7.2-cli \
        php7.2-fpm \
        php7.2-xdebug \
        git \
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

COPY dev.ini /etc/php/7.2/mods-available/dev.ini
RUN phpenmod dev

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 9000
CMD ["php-fpm7.2", "--nodaemonize", "--fpm-config", "/etc/php/7.2/fpm/php-fpm.conf"]

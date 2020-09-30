FROM quay.io/cuppett/fedora-s2i-php-base:latest

ENV SUMMARY="PHP FPM image which allows using of source-to-image, PHP commands and Smarty templates."	\
    DESCRIPTION="The php-fpm image provides any images layered on top of it \
with all the tools needed to use php-fpm and/or source-to-image functionality while keeping \
the image size as small as possible." \
    NAME=fedora-s2i-php-fpm \
    VERSION=32

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="$NAME" \
      com.redhat.component="$NAME" \
      name="$FGC/$NAME" \
      version="$VERSION" \
      usage="This image is supposed to be used as a base image for other images that support php-fpm or source-to-image" \
      maintainer="Stephen Cuppett <steve@cuppett.com>"

USER 0

# install a robust FPM environment, composer + common webapp extensions
RUN set -ex; \
    \
    dnf -y install \
        composer \
        php-bcmath \
        php-fpm \
        php-gd \
        php-gmp \
        php-intl \
        php-json \
        php-mysqlnd \
        php-opcache \
        php-pecl-apcu \
        php-pecl-imagick \
        php-pecl-mongodb \
        php-pecl-redis \ 
        php-pecl-zip \
        php-pgsql \ 
        php-soap \
        php-xml \
    ; \
    \
# reset dnf cache
    dnf -y clean all; \
    rm -rf /var/cache/dnf

COPY smarty /usr/local/src/smarty
# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY s2i/bin/ $STI_SCRIPTS_PATH

# set permissions up on the runtime locations
RUN set -ex; \
    mkdir /run/php-fpm; \
    mkdir -p /tmp/php/{session,wsdlcache}; \
    chgrp -R 0 /etc/php* ; \
    chmod g+w -R /etc/php* ; \
    fix-permissions /run/php-fpm; \
    fix-permissions /tmp/php; \
    fix-permissions /var/www; \
    /usr/bin/php /usr/local/src/smarty/compile_templates.php

# PHP-FPM defaults
ENV PHP_FPM_PM="ondemand"
ENV PHP_FPM_MAX_CHILDREN="8"
ENV PHP_FPM_START_SERVERS=""
ENV PHP_FPM_MIN_SPARE_SERVERS=""
ENV PHP_FPM_MAX_SPARE_SERVERS=""
ENV PHP_FPM_MAX_REQUESTS=""

# PHP Admin Settings
ENV PHP_POST_MAX_SIZE="32M"
ENV PHP_UPLOAD_MAX_FILESIZE="2M"
ENV PHP_MAX_FILE_UPLOADS="20"
ENV PHP_MAX_INPUT_VARS="1000"

# OPcache defaults
ENV PHP_OPCACHE_ENABLE="1"
ENV PHP_OPCACHE_MEMORY_CONSUMPTION="128"
ENV PHP_OPCACHE_MAX_ACCELERATED_FILES="10000"
ENV PHP_OPCACHE_INTERNED_STRINGS_BUFFER="8"
ENV PHP_OPCACHE_SAVE_COMMENTS="1"
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="1"
ENV PHP_OPCACHE_FILE_UPDATE_PROTECTION="2"
ENV PHP_OPCACHE_REVALIDATE_FREQ="2"

# Override stop signal to stop process gracefully
# https://github.com/php/php-src/blob/17baa87faddc2550def3ae7314236826bc1b1398/sapi/fpm/php-fpm.8.in#L163
STOPSIGNAL SIGQUIT

EXPOSE 9000

VOLUME /var/www/html

USER 1001

CMD ["/usr/sbin/php-fpm"]

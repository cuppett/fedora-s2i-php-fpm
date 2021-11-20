#!/bin/sh
set -e

/usr/bin/php /usr/local/src/smarty/process_templates.php

PhpVer="${PHP_VERSION:-dist}"

if [ "$PhpVer" = "7.4" ]
then
  . /opt/rh/php74/enable
fi

exec "$@"
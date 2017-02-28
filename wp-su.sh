#!/bin/sh
# This is a wrapper so that wp-cli can run as the www-data user so that permissions
# remain correct
sudo -u www-data /bin/wp-cli.phar "$@"


# Setup PHPUnit.
# Source: https://github.com/chriszarate/docker-wordpress/blob/master/docker-entrypoint.sh
if [ -f /tmp/wordpress/latest/wp-tests-config-sample.php ]; then
  sed \
    -e "s/.*ABSPATH.*/define( 'ABSPATH', getenv('WP_ABSPATH') );/" \
    -e "s/.*DB_HOST.*/define( 'DB_HOST', '${PHPUNIT_DB_HOST:-mysql_phpunit}' );/" \
    -e "s/.*DB_NAME.*/define( 'DB_NAME', '${PHPUNIT_DB_NAME:-wordpress_phpunit}' );/" \
    -e "s/.*DB_USER.*/define( 'DB_USER', '${PHPUNIT_DB_USER:-root}' );/" \
    -e "s/.*DB_PASSWORD.*/define( 'DB_PASSWORD', '$PHPUNIT_DB_PASSWORD' );/" \
    /tmp/wordpress/latest/wp-tests-config-sample.php > /tmp/wordpress/latest/wp-tests-config.php

  # Link resources needed for tests.
  for link in $PHPUNIT_WP_CONTENT_LINKS; do
    if ! [ -d "/tmp/wordpress/latest/src/wp-content/$link" ]; then
      mkdir -p "$(dirname "/tmp/wordpress/latest/src/wp-content/$link")"
      ln -s "/var/www/html/wp-content/$link" "/tmp/wordpress/latest/src/wp-content/$link" || echo "Symlink $link already exists."
    fi
  done

  # Create writeable uploads directory.
  # shellcheck disable=SC2174
  mkdir -p -m 777 /tmp/wordpress/latest/src/wp-content/uploads
fi
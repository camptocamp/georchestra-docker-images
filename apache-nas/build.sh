#!/bin/bash

set -e

apt update

# configure sendmail and php to use georchestra-smtp-svc as mail server
apt install -y --no-install-recommends --no-install-suggests libpq-dev ssmtp
sed -i "s/mailhub=mail/mailhub=georchestra-smtp-svc/" /etc/ssmtp/ssmtp.conf
sed -i 's/#FromLineOverride=YES/FromLineOverride=YES/' /etc/ssmtp/ssmtp.conf
printf "[mail function]\nsendmail_path = /usr/sbin/ssmtp -t\n" > /usr/local/etc/php/conf.d/sendmail.ini

# install additional extensions
apt install -y --no-install-recommends --no-install-suggests libzip-dev
docker-php-ext-install pgsql pdo_pgsql zip

# configure apache2
chown -R www-data /run/apache2 /run/lock/apache2 /var/cache/apache2/mod_cache_disk /var/log/apache2
printf "upload_max_filesize=50M\npost_max_size=50M\n" > /usr/local/etc/php/conf.d/upload-size-customizations.ini
a2enmod rewrite

apt-get clean
rm -rf /var/lib/apt/lists/*
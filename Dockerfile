# https://github.com/uselauncher/php-fpm-81
# https://hub.docker.com/r/uselauncher/php-fpm-81
FROM php:8.1-fpm-buster

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN set -ex \
  && apt-get update \
  && apt-get install -y git libonig-dev libzip-dev zip unzip lsb-release wget gnupg nano vim procps jpegoptim optipng pngquant gifsicle

# Install MySQL client so we can run mysqldump
RUN set -ex \
  && cd /tmp \
  && curl https://repo.mysql.com/mysql-apt-config_0.8.17-1_all.deb -O \
  && DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config_0.8.17-1_all.deb \
  && curl -s http://repo.mysql.com/RPM-GPG-KEY-mysql-2022 | apt-key add - \
  && apt-get update \
  && apt-get install -y mysql-client

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# php:8.1-fpm is Debian-10 based, so we use the Debian10 intallation instructrions
RUN set -ex \
  && curl -fsSL https://deb.nodesource.com/setup_14.x | bash - \
  && apt-get install -y nodejs \
  && npm install -g yarn svgo \
  \
  # Install PHP extensions
  && install-php-extensions bcmath dom exif gd intl imagick mysqli pdo_mysql pdo_pgsql pcntl redis soap simplexml tokenizer zip \
  \
  # Clear cache
  && apt-get clean && rm -rf /var/lib/apt/lists/* \
  \
  # Add user to run the laravel application
  && groupadd -g 1000 launcher \
  && useradd -u 1000 -ms /bin/bash -g launcher launcher

WORKDIR /app
USER launcher
CMD ["php-fpm"]

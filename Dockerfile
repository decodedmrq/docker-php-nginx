FROM php:8-fpm-alpine

# Setup document root
WORKDIR /var/www/app

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/

# Install packages and remove default server definition
RUN apk update && apk add --no-cache \
  nginx \
  build-base \
  curl \
  supervisor

RUN apk add --no-cache $PHPIZE_DEPS zlib-dev \
   && install-php-extensions grpc protobuf \
   && docker-php-ext-enable grpc protobuf

# compile native PHP packages
RUN docker-php-ext-install bcmath pdo_mysql exif pcntl

RUN pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis

# Configure nginx
COPY  ./nginx/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY ./php/php.ini /usr/local/etc/php/php.ini
COPY ./php/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY ./php/www.conf /usr/local/etc/php-fpm.d/www.conf

# Configure supervisord
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY ./php/*.sh /scripts/
RUN chmod a+x /scripts/*.sh

# Expose the port nginx is reachable on
EXPOSE 80

ENTRYPOINT ["sh", "/scripts/entrypoint.sh"]

# Let supervisord start nginx & php-fpm when run container
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

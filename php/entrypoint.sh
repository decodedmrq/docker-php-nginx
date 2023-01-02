#!/bin/sh

# Run migrate for new migration files
echo "----- LARAVEL MIGRATE START -----"
php artisan migrate
echo "----- LARAVEL MIGRATE FINISH  -----"

# Clear and cache config
echo "----- LARAVEL OPTIMIZE -----"
php artisan optimize
echo "----- LARAVEL OPTIMIZED  -----"

exec "$@"

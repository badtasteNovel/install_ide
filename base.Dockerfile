# syntax=docker/dockerfile:1
# image-name: my-php-base:8.4
FROM php:8.4-fpm-bookworm

# 1. 確保基礎套件包含執行時期與編譯時期的 libpq
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    libpq5 \
    libpng-dev libjpeg-dev libfreetype6-dev libzip-dev libicu-dev libxml2-dev \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 2. 安裝 PostgreSQL 驅動 (將 pdo_pgsql 置於前端)
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_pgsql \
        pgsql \
        gd zip intl bcmath opcache sockets pcntl

# 3. 分開安裝 PECL 擴充 (grpc 建議最後安裝，避免干擾核心擴充)
RUN pecl install redis && docker-php-ext-enable redis \
    && pecl install grpc && docker-php-ext-enable grpc

# 4. 強制清理編譯殘留
RUN apt-get purge -y --auto-remove libpq-dev

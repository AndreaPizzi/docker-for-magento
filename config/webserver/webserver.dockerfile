FROM ubuntu:18.04

#set tzdata (geographic zone)
#made to prevent error while installing
ENV TZ=Europe/Rome
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#install prerequisites
RUN apt-get update && apt-get install -y \
    software-properties-common \
    sudo \
    git \
	composer \
    nginx \
    systemd
	
#setup a custom php version for compatibility
RUN add-apt-repository ppa:ondrej/php -y
RUN apt-get update && apt-get install -y \
    php7.1-fpm \
    php7.1-mcrypt \
    php7.1-curl \
    php7.1-cli \
    php7.1-mysql \
    php7.1-gd \
    php7.1-xsl \
    php7.1-json \
    php7.1-intl \
    php-pear \
    php7.1-dev \
    php7.1-common \
    php7.1-mbstring \
    php7.1-zip \
    php7.1-soap \
    php7.1-bcmath

# Configure stuffs
RUN sed -i "s/memory_limit = .*/memory_limit = 1024M/" /etc/php/7.1/fpm/php.ini
RUN sed -i "s/upload_max_filesize = .*/upload_max_filesize = 256M/" /etc/php/7.1/fpm/php.ini
RUN sed -i "s/zlib.output_compression = .*/zlib.output_compression = on/" /etc/php/7.1/fpm/php.ini
RUN sed -i "s/max_execution_time = .*/max_execution_time = 18000/" /etc/php/7.1/fpm/php.ini
RUN sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.1/fpm/php.ini
RUN sed -i "s/;opcache.save_comments.*/opcache.save_comments = 1/" /etc/php/7.1/fpm/php.ini


# Install Xdebug (but don't enable)
#RUN pecl install -o -f xdebug

#configure magento use
RUN adduser beprime --gecos "beprime User,,," --disabled-password
RUN echo "beprime:Abcd1234!#$" | chpasswd
RUN usermod -a -G www-data beprime

#configure source
WORKDIR /var/www/html
RUN chown -R :www-data .
#USER magento
#RUN find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
#RUN find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
#RUN chmod u+x bin/magento

# Add files.
#ADD root/.bashrc /root/.bashrc
#ADD root/.gitconfig /root/.gitconfig
#ADD root/.scripts /root/.scripts

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

RUN echo "log_errors = On" >> /etc/php/7.1/fpm/php.ini
RUN echo "error_log = /dev/stderr" >> /etc/php/7.1/fpm/php.ini

# run services
RUN update-alternatives --set php /usr/bin/php7.1
RUN service php7.1-fpm restart
RUN service nginx restart

EXPOSE 80

STOPSIGNAL SIGTERM

CMD service php7.1-fpm start && nginx -g 'daemon off;'
#CMD ["nginx", "-g", "daemon off;"]
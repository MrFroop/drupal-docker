# dockerized drupal development box
# includes apache, php, xhprof, imagemagick, sshd and drush
# No mysql, use a dedicated mysql-docker-image and link the container.
#
# VERSION               php-70
# DOCKER-VERSION        2
FROM    debian:jessie

MAINTAINER Stephan Maximilian Huber <stephan@factorial.io>

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

RUN export debian_frontend=noninteractive && apt-get update --fix-missing && apt-get -y -q install git mysql-client wget

# Prepare php7
RUN echo 'deb http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list
RUN echo 'deb-src http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list
RUN /usr/bin/wget -qO - https://www.dotdeb.org/dotdeb.gpg | apt-key add -

RUN export debian_frontend=noninteractive && apt-get update --fix-missing && apt-get -y -q install unzip apache2 pwgen python-setuptools vim-tiny openssh-server vim curl graphviz make imagemagick libapache2-mod-php7.0 php7.0-mysql php7.0-curl php7.0-memcache php7.0-mcrypt php7.0-redis php7.0-mbstring php7.0-gd php7.0-dom php7.0-xml

# composer and drush
run curl -ss https://getcomposer.org/installer | php
run mv composer.phar /usr/local/bin/composer
run /usr/local/bin/composer global require "hirak/prestissimo:^0.3"
run /usr/local/bin/composer global require drush/drush:8.1.4
RUN sed -i '1i export PATH="/.composer/vendor/bin:$HOME/.composer/vendor/bin:$PATH"' /root/.bashrc


# sshd
RUN DEBIAN_FRONTEND=noninteractive apt-get autoclean
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
RUN mkdir /var/run/sshd
RUN echo 'root:root' |chpasswd

# configure apache
RUN sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
RUN a2enmod rewrite vhost_alias

VOLUME ["/var/www"]


RUN easy_install supervisor
ADD ./start.sh /start.sh
ADD ./foreground.sh /etc/apache2/foreground.sh
ADD ./apache-vhost.conf /etc/apache2/sites-available/000-default.conf
ADD ./supervisord.conf /etc/supervisord.conf
ADD ./php.ini /etc/php5/apache2/php.ini
ADD ./xhprof.conf /etc/apache2/conf.d/xhprof.conf
ADD ./phpsendmail /usr/local/bin/phpsendmail
RUN chmod +x /usr/local/bin/phpsendmail
RUN touch /var/log/mail_php.log
RUN chmod 777 /var/log/mail_php.log
RUN touch /var/log/php_errors.log
RUN chmod 777 /var/log/php_errors.log

RUN chmod 755 /start.sh /etc/apache2/foreground.sh
EXPOSE 80
CMD ["/bin/bash", "/start.sh"]

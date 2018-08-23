FROM ubuntu:14.04

MAINTAINER Sanjay Maurya <sanjayabc1234@gmail.com>

LABEL Description = "Version 7 old php5 setup based on Ubuntu 14.04 LTS. It includes LAMP stack tailored for old stack. Usage='docker run -p [HOST WWW PORT NUMBER]:80 -v [HOST WWW DOCUMENT ROOT]:/var/www/html ubuntu:14.04 bash'"

RUN apt-get update

#ENV http_proxy=http://user:pass@host:port
#ENV https_proxy=http://user:pass@host:port


ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get install -y build-essential curl zip unzip nano

RUN apt-get install apache2 libapache2-mod-php5 -y
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN sed -i "13 i \ \n\t# Added automatically using dockerfile\n\t<Directory /var/www/html>\n\t\tOptions Indexes FollowSymLinks MultiViews\n\t\tAllowOverride All\n\t\tRequire all granted\n\t</Directory>\n" /etc/apache2/sites-available/000-default.conf
RUN sed -i '30 a \ \n\t# Added automatically using dockerfile\n\t<IfModule mod_dir.c>\n\t\tDirectoryIndex index.php index.pl index.cgi index.html index.xhtml index.htm\t\n\t</IfModule>\n' /etc/apache2/sites-available/000-default.conf

RUN a2enmod rewrite
RUN service apache2 restart

RUN apt-get install -y php5 php5-cli php5-common php5-curl php5-dev php5-gd php5-imap php5-json php5-mcrypt php5-mysql php-pear pkg-config libssl-dev libsslcommon2-dev

RUN pecl install mongo

RUN php5enmod mcrypt

RUN echo "extension=mongo.so" >> /etc/php5/cli/php.ini
RUN echo "extension=mongo.so" >> /etc/php5/apache2/php.ini

COPY index.php /var/www/html/
COPY run-lamp.sh /usr/sbin/
RUN chmod +x /usr/sbin/run-lamp.sh

VOLUME /var/www/html
VOLUME /var/log/httpd
VOLUME /etc/apache2

RUN echo "root:ser_123" | chpasswd
RUN service apache2 restart

RUN groupadd dev
RUN useradd -d /home/dev -u 1000 -g dev dev
RUN echo 'dev:ser_123' | chpasswd
RUN usermod -aG sudo dev
USER dev
WORKDIR /home/dev
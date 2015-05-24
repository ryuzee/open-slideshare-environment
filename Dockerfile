FROM ubuntu:14.04

## Web
RUN apt-get update && apt-get install -y curl php5 php5-cli php5-fpm php5-mysql php-pear php5-curl php5-xsl php5-mcrypt php5-gd mysql-server-5.5 nginx git wget
RUN wget http://getcomposer.org/composer.phar -O /usr/local/bin/composer.phar && chmod 755 /usr/local/bin/composer.phar
RUN apt-get install -y php5-xdebug nginx supervisor
RUN apt-get install -y python-pip && pip install supervisor-stdout

## Worker
RUN apt-get install -y unoconv imagemagick xpdf xvfb fonts-vlgothic fonts-mplus fonts-migmix
RUN wget http://downloads.sourceforge.net/project/openofficeorg.mirror/4.1.1/binaries/ja/Apache_OpenOffice_4.1.1_Linux_x86-64_install-deb_ja.tar.gz -O /tmp/openoffice.tar.gz && cd /tmp && tar xvfz openoffice.tar.gz && cd ja/DEBS && dpkg -i *.deb

ADD docker/templates/nginx/default /etc/nginx/sites-enabled/default
ADD docker/templates/supervisord/supervisord.conf /etc/supervisord.conf
ADD docker/templates/start.php /start.php
RUN chmod 755 /start.php
ADD application /var/www/application/current
RUN chmod -R 777 /var/www/application/current/app/tmp/

# Port
EXPOSE 22 80 443

# コンテナを実行した時のコマンド
CMD ["/start.php"]

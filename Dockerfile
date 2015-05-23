FROM ubuntu:14.04

RUN apt-get update && apt-get install -y curl php5 php5-cli php5-fpm php5-mysql php-pear php5-curl php5-xsl php5-mcrypt php5-gd mysql-server-5.5 nginx git wget
RUN wget http://getcomposer.org/composer.phar -O /usr/local/bin/composer.phar && chmod 755 /usr/local/bin/composer.phar
RUN apt-get install -y php5-xdebug nginx supervisor
ADD docker/templates/nginx/default /etc/nginx/sites-enabled/default
ADD docker/templates/supervisord/supervisord.conf /etc/supervisord.conf
ADD application /var/www/application/current

# Port
EXPOSE 22 80 443

# コンテナを実行した時のコマンド
CMD ["/usr/local/bin/supervisord", "-n"]

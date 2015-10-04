#!/bin/bash -v
# You have to set these environment variables as follows.
# OSS_BUCKET_NAME
# OSS_IMAGE_BUCKET_NAME
# OSS_USE_S3_STATIC_HOSTING
# OSS_CDN_BASE_URL
# OSS_REGION
# OSS_SQS_URL

if [ -f ./export.sh ]; then
  source ./export.sh
fi

if [ ! -v DEPLOY_USER ]; then
  DEPLOY_USER=ubuntu
fi

if [ ! -v DEPLOY_GROUP ]; then
  DEPLOY_GROUP=ubuntu
fi

apt-get update
apt-get install -y build-essential autoconf curl wget unzip git

######## install chef ########
if test `dpkg -l | grep chefdk | wc -l` -eq 0
then
  wget https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chefdk_0.7.0-1_amd64.deb -O /tmp/chefdk_0.7.0-1_amd64.deb
  dpkg -i /tmp/chefdk_0.7.0-1_amd64.deb
fi

######## Sent environment ########
export HOME=/tmp
export PATH=/opt/chefdk/embedded/bin:$PATH

######## delete files ########
\rm /tmp/environment.zip
\rm /tmp/app.zip
\rm -rf /tmp/open-slideshare-environment-master
\rm -rf /tmp/open-slideshare-master

######## get script for setup environment #######
wget https://github.com/ryuzee/open-slideshare-environment/archive/master.zip -O /tmp/environment.zip
cd /tmp/ && unzip environment.zip

mkdir -p /var/chef-solo && mkdir -p /etc/chef
######## solo.rb ########
echo 'log_level :info' > /etc/chef/solo.rb
echo 'log_location "/var/chef-solo/result.log"' >> /etc/chef/solo.rb
echo 'file_cache_path "/var/chef-solo"' >> /etc/chef/solo.rb
echo 'cookbook_path "/tmp/open-slideshare-environment-master/cookbooks/"' >> /etc/chef/solo.rb

######## solo.json ########
cp /tmp/open-slideshare-environment-master/solo.json.sample /etc/chef/solo.json
sed -i -e "s|##OSS_RDS_HOSTNAME##|$OSS_RDS_HOSTNAME|g" /etc/chef/solo.json
sed -i -e "s|##OSS_RDS_USERNAME##|$OSS_RDS_USERNAME|g" /etc/chef/solo.json
sed -i -e "s|##OSS_RDS_PASSWORD##|$OSS_RDS_PASSWORD|g" /etc/chef/solo.json
sed -i -e "s|##OSS_RDS_DB_NAME##|$OSS_RDS_DB_NAME|g" /etc/chef/solo.json
sed -i -e "s|##OSS_AWS_ACCESS_ID##|$OSS_AWS_ACCESS_ID|g" /etc/chef/solo.json
sed -i -e "s|##OSS_AWS_SECRET_KEY##|$OSS_AWS_SECRET_KEY|g" /etc/chef/solo.json
sed -i -e "s|##OSS_BUCKET_NAME##|$OSS_BUCKET_NAME|g" /etc/chef/solo.json
sed -i -e "s|##OSS_IMAGE_BUCKET_NAME##|$OSS_IMAGE_BUCKET_NAME|g" /etc/chef/solo.json
sed -i -e "s|##OSS_USE_S3_STATIC_HOSTING##|$OSS_USE_S3_STATIC_HOSTING|g" /etc/chef/solo.json
sed -i -e "s|##OSS_CDN_BASE_URL##|$OSS_CDN_BASE_URL|g" /etc/chef/solo.json
sed -i -e "s|##OSS_REGION##|$OSS_REGION|g" /etc/chef/solo.json
sed -i -e "s|##OSS_SQS_URL##|$OSS_SQS_URL|g" /etc/chef/solo.json

cd /tmp/open-slideshare-environment-master && /opt/chefdk/embedded/bin/bundle install && /opt/chefdk/embedded/bin/berks vendor cookbooks
/usr/bin/chef-solo -c /etc/chef/solo.rb -j /etc/chef/solo.json

######## install application ########
wget https://github.com/ryuzee/open-slideshare/archive/master.zip -O /tmp/app.zip
cd /tmp && unzip app.zip
REL=`date +%Y%m%d%H%M%S`
mkdir -p /var/www/application/releases/$REL
cp -Rp /tmp/open-slideshare-master/ -T /var/www/application/releases/$REL
chown -R $DELOY_USER:$DEPLOY_GROUP /var/www/application/releases/$REL
if [ ! -n "`readlink /var/www/application/current`" ]; then rm -rf /var/www/application/current; fi
ln -s /var/www/application/releases/$REL /var/www/application/current
chown $DELOY_USER:$DEPLOY_GROUP /var/www/application/current
chmod -R 777 /var/www/application/current/app/tmp/
cd /var/www/application/current && php composer.phar install
chmod 755 /var/www/application/current/app/Console/cake
cd /var/www/application/current && app/Console/cake Migrations.migration run all
cd /var/www/application/current && app/Console/cake Migrations.migration run all -p Tags
reboot

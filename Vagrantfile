# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define :develop do |develop|
    develop.omnibus.chef_version = :latest
    develop.vm.hostname = "develop"
    develop.vm.box = "opscode-ubuntu-14.04"
    develop.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-14.04_chef-provisionerless.box"
    develop.vm.network :private_network, ip: "192.168.33.33"
    develop.vm.network "forwarded_port", guest: 80, host: 8888

    # 以下を追加
    # Vagrantfileがあるディレクトリと同じディレクトリのapplicationディレクトリをVagrantと共有します
    # 先にapplicationディレクトリを作成しておいてください。
    develop.vm.synced_folder "application", "/var/www/application/current",
      id: "vagrant-root", :nfs => false,
      :owner => "vagrant",
      :group => "www-data",
      :mount_options => ["dmode=775,fmode=775"]
    # 追加ここまで
    # 以下のプロビジョニングの設定を追加
    develop.vm.provision :chef_solo do |chef|
      chef.log_level = "debug"
      chef.cookbooks_path = "./cookbooks"
      chef.json = {
        nginx: {
          docroot: {
            owner: "vagrant",
            group: "vagrant",
            path: "/var/www/application/current/app/webroot",
            force_create: true
          },
          default: {
            fastcgi_params: {  OSS_CAKE_ENV: "development" }
          },
          test: {
            available: true,
            fastcgi_params: {  OSS_CAKE_ENV: "test" }
          }
        },
        mysql: {
          accept_connection_from_outside: true,
          app_database_name: "openslideshare",
          app_database_user: "webapp",
          app_database_password: "passw0rd"
        },
        appenv: {
          OSS_RDS_HOSTNAME: "localhost",
          OSS_RDS_USERNAME: "webapp",
          OSS_RDS_PASSWORD: "passw0rd",
          OSS_RDS_DB_NAME: "openslideshare",
          OSS_AWS_ACCESS_ID: ENV['OSS_AWS_ACCESS_ID'],
          OSS_AWS_SECRET_KEY: ENV['OSS_AWS_SECRET_KEY'],
          OSS_BUCKET_NAME: ENV['OSS_BUCKET_NAME'],
          OSS_IMAGE_BUCKET_NAME: ENV['OSS_IMAGE_BUCKET_NAME'],
          OSS_USE_S3_STATIC_HOSTING: ENV['OSS_USE_S3_STATIC_HOSTING'],
          OSS_CDN_BASE_URL: ENV['OSS_CDN_BASE_URL'],
          OSS_REGION: ENV['OSS_REGION'],
          OSS_SQS_URL: ENV['OSS_SQS_URL'],
          OSS_DEBUG: "2",
          OSS_BATCH_USER: "vagrant"
        }
      }
      chef.run_list = %w[
        recipe[apt]
        recipe[phpenv::default]
        recipe[phpenv::composer]
        recipe[phpenv::develop]
        recipe[appenv::default]
        recipe[appenv::worker]
      ]
    end
  end
end

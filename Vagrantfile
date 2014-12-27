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
            fastcgi_params: {  CAKE_ENV: "development" }
          },
          test: {
            available: true,
            fastcgi_params: {  CAKE_ENV: "test" }
          }
        },
        mysql: {
          app_database_name: "openslideshare",
          app_database_user: "webapp",
          app_database_password: "passw0rd"
        },
        appenv: {
          RDS_HOSTNAME: "localhost",
          RDS_USERNAME: "webapp",
          RDS_PASSWORD: "passw0rd",
          RDS_DB_NAME: "openslideshare",
          AWS_ACCESS_ID: ENV['AWS_ACCESS_ID'],
          AWS_SECRET_KEY: ENV['AWS_SECRET_KEY'],
          BUCKET_NAME: ENV['OSS_BUCKET_NAME'],
          IMAGE_BUCKET_NAME: ENV['OSS_IMAGE_BUCKET_NAME'],
          REGION: ENV['OSS_REGION'],
          SQS_URL: ENV['OSS_SQS_URL'],
          DEBUG: "2"
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

#
# Cookbook Name:: phpenv
# Recipe:: default
#
# Copyright 2014, Ryutaro YOSHIBA
#
# # This software is released under the MIT License.
# http://opensource.org/licenses/mit-license.php

%w{curl php5 php5-cli php5-fpm php5-mysql php-pear php5-curl php5-xsl php5-mcrypt php5-gd mysql-server-5.5 nginx git}.each do |p|
  package p do
    action :install
  end
end

# mcryptモジュールを有効にする
execute "php5enmod mcrypt" do
  action :run
end

# 今回はApacheは利用しないので、パッケージがインストール済の場合はサービスを停止し無効化する
service "apache2" do
  action [:disable, :stop]
  only_if "dpkg -l | grep apache2"
end

# Nginx用の設定ファイルをテンプレートから作成する
template "/etc/nginx/sites-available/test" do
  source "test.erb"
  owner "root"
  group "root"
  mode 0644
  action :create
  only_if { node['nginx']['test']['available'] == true }
end

# シンボリックリンクを張って設定ファイルを有効化する
link "/etc/nginx/sites-enabled/test" do
  to "/etc/nginx/sites-available/test"
  only_if { node['nginx']['test']['available'] == true }
end

# Defaultの設定ファイルを作成する
template "/etc/nginx/sites-available/default" do
  source "default.erb"
  owner "root"
  group "root"
  mode 0644
  action :create
end

# Nginxのドキュメントルートを作成する
directory node['nginx']['docroot']['path'] do
  owner node['nginx']['docroot']['owner']
  group node['nginx']['docroot']['group']
  mode 0755
  action :create
  recursive true
  only_if { not File.exists?(node['nginx']['docroot']['path']) and node['nginx']['docroot']['force_create']}
end

# ダミーのphpスクリプトを作成する
template "#{node['nginx']['docroot']['path']}/index.php" do
  source "index.php.erb"
  owner node['nginx']['docroot']['owner']
  group node['nginx']['docroot']['group']
  mode 0644
  action :create
  only_if { not File.exists?("#{node['nginx']['docroot']['path']}/index.php") and node['nginx']['docroot']['force_create']}
end

# 外部からのコネクションを受け付ける
execute "sed -i -e 's/bind-address\t\t= 127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/my.cnf" do
  action :run
  only_if { node['mysql']['accept_connection_from_outside'] == true }
end

# Nginxのサービスを有効化して起動する
service "nginx" do
  action [:enable, :restart]
end

# MySQLのサービスを有効化して起動する
service "mysql" do
  action [:enable, :restart]
  supports :status => true, :start => true, :stop => true, :restart => true
  not_if do File.exists?("/var/run/mysql.pid") end
end

# MySQLのrootアカウントのパスワードをセットする
execute "set_mysql_root_password" do
  command "/usr/bin/mysqladmin -u root password \"#{node['mysql']['root_password']}\""
  action :run
  only_if "/usr/bin/mysql -u root -e 'show databases;'"
end

include_recipe 'database::mysql'

# MySQLのデータベースを作成する
mysql_connection_info = {:host => "localhost",
                         :username => 'root',
                         :password => node['mysql']['root_password']}

mysql_database node['mysql']['app_database_name'] do
  connection mysql_connection_info
  encoding 'utf8'
  action :create
end

# MySQL用のユーザーを作成する
mysql_database_user node['mysql']['app_database_user'] do
  connection mysql_connection_info
  password node['mysql']['app_database_password']
  database_name node['mysql']['app_database_name']
  privileges [:all]
  action [:create, :grant]
end

mysql_database_user node['mysql']['app_database_user'] do
  connection mysql_connection_info
  password node['mysql']['app_database_password']
  database_name node['mysql']['app_database_name']
  privileges [:all]
  action [:create, :grant]
  host '%'
  only_if { node['mysql']['accept_connection_from_outside'] == true }
end

# vim: filetype=ruby.chef

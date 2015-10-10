#
# Cookbook Name:: devtool
# Recipe:: default
#
# Copyright 2015, Ryutaro Yoshiba
#

execute "wget git.io/nodebrew -O /tmp/nodebrew && perl /tmp/nodebrew setup" do
  user  'vagrant'
  environment 'HOME' => "/home/vagrant"
  action :run
end

execute "nodebrew install-binary v4.1.1 && nodebrew use v4.1.1" do
  user  'vagrant'
  environment(
    'USER' => 'vagrant',
    'HOME' => "/home/vagrant",
    'PATH' => "/home/vagrant/.nodebrew/current/bin:/usr/bin"
  )
  action :run
  not_if "node -v"
end

execute "npm install -g grunt-cli" do
  user  'vagrant'
  environment(
    'USER' => 'vagrant',
    'HOME' => "/home/vagrant",
    'PATH' => "/home/vagrant/.nodebrew/current/bin:/usr/bin"
  )
  action :run
end

ruby_block "add path" do
  block do
    file = Chef::Util::FileEdit.new("/home/vagrant/.bashrc")
    file.insert_line_if_no_match(
      "PATH=$HOME/.nodebrew/current/bin:$PATH",
      "PATH=$HOME/.nodebrew/current/bin:$PATH"
    )
    file.write_file
  end
end

include_recipe 'database::mysql'

mysql_connection_info = {:host => "localhost",
                         :username => 'root',
                         :password => node['mysql']['root_password']}

mysql_database 'test_openslideshare' do
  connection mysql_connection_info
  encoding 'utf8'
  action :create
end

mysql_database_user 'webapp' do
  connection mysql_connection_info
  password 'passw0rd'
  database_name 'test_openslideshare'
  privileges [:all]
  action [:create, :grant]
end

# vim: filetype=ruby.chef

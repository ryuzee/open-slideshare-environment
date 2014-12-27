#
# Cookbook Name:: appenv
# Recipe:: default
#
# Copyright 2014, Ryutaro YOSHIBA
#
# # This software is released under the MIT License.
# http://opensource.org/licenses/mit-license.php

template "/etc/profile.d/appenv.sh" do
  source "appenv.sh.erb"
  owner "root"
  group "root"
  mode "00755"
end

template "/etc/nginx/sites-enabled/default" do
  source "default.erb"
  owner "root"
  group "root"
  mode "00644"
  notifies :restart, "service[nginx]"
end

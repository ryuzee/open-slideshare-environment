#
# Cookbook Name:: appenv
# Recipe:: worker
#
# Copyright 2014, Ryutaro YOSHIBA
#
# # This software is released under the MIT License.
# http://opensource.org/licenses/mit-license.php

%w{unoconv imagemagick xpdf xvfb fonts-vlgothic fonts-mplus fonts-migmix}.each do |package_name|
  package package_name do
    action :install
  end
end

remote_file "#{Chef::Config[:file_cache_path]}/openoffice.tar.gz" do
  source "http://downloads.sourceforge.net/project/openofficeorg.mirror/4.1.1/binaries/ja/Apache_OpenOffice_4.1.1_Linux_x86-64_install-deb_ja.tar.gz"
  mode 0644
end

execute "tar xvfz #{Chef::Config[:file_cache_path]}/openoffice.tar.gz && cd ja/DEBS && dpkg -i *.deb" do
  action :run
end

package "supervisor" do
  action :install
end

service "supervisor" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

template "/etc/supervisor/conf.d/01_unoconv.conf" do
  source "01_unoconv.conf.erb"
  owner "root"
  group "root"
  mode "00644"
  notifies :restart, "service[supervisor]"
end

template "/etc/supervisor/conf.d/02_convert.conf" do
  source "02_convert.conf.erb"
  owner "root"
  group "root"
  mode "00644"
  notifies :restart, "service[supervisor]"
end

hostsfile_entry '127.0.0.1' do
  hostname  'test.localhost'
  action    :append
end

package "php5-xdebug" do
  action :install
end

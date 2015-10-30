set :stage, :development
role :web, %w{192.168.33.100}
server '192.168.33.100', user: 'vagrant', password: 'vagrant'
set :branch, 'master'

lock '3.4.0'

set :application, 'open-slideshare'
set :scm, :git
set :repo_url, 'https://github.com/ryuzee/open-slideshare.git'
set :deploy_to, '/var/www/application'
set :format, :pretty
set :log_level, :debug
set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 3

Dir.glob('lib/capistrano/tasks/*').each { |r|
  import r
}

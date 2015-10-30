namespace :custom do
  desc <<-DESC
    Setup directory
  DESC
  task :setup_directory do
    on roles (:web) do
      execute "sudo mkdir -p /var/www/application/ && sudo chmod 777 /var/www/application"
    end
  end

  desc <<-DESC
    Custom procedure...
  DESC
  task :unlink do
    on roles (:web) do
      execute "if [ ! -n \"`readlink /var/www/application/current`\" ]; then sudo rm -rf /var/www/application/current; fi"
    end
  end

  desc <<-DESC
    Change permission for application temp directory
  DESC
  task :tmp_directory_writable do
    on roles (:web) do
      execute "cd #{release_path} && chmod -R 777 app/tmp"
    end
  end

  desc <<-DESC
    Install composer
  DESC
  task :install_composer do
    on roles (:web) do
      execute "cd #{release_path} && php composer.phar install"
    end
  end

  desc <<-DESC
    Run database migration
  DESC
  task :migrate do
    on roles (:web) do
      cmd =<<"EOS"
chmod 755 #{release_path}/app/Console/cake && \
cd #{release_path} && app/Console/cake Migrations.migration run all && \
cd #{release_path} && app/Console/cake Migrations.migration run all -p Tags
EOS
      execute "#{cmd}"
    end
  end

  before 'deploy', 'custom:unlink'
  before 'custom:unlink', 'custom:setup_directory'
  before 'deploy:symlink:release', 'custom:tmp_directory_writable'
  before 'deploy:symlink:release', 'custom:install_composer'
  after 'custom:install_composer', 'custom:migrate'
end

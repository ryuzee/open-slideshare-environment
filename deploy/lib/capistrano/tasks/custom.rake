namespace :custom do
  desc <<-DESC
    Custom procedure...
  DESC
  task :unlink do
    on roles (:web) do
      execute "if [ ! -n \"`readlink /var/www/application/current`\" ]; then rm -rf /var/www/application/current; fi"
    end
  end

  task :change_permission do
    on roles (:web) do
      execute "cd #{release_path} && chmod -R 777 app/tmp"
    end
  end

  task :install_composer do
    on roles (:web) do
      execute "cd #{release_path} && php composer.phar install"
    end
  end

  task :migrate do
    on roles (:web) do
      cmd =<<"EOS"
chmod 755 /var/www/application/current/app/Console/cake && \
cd /var/www/application/current && app/Console/cake Migrations.migration run all && \
cd /var/www/application/current && app/Console/cake Migrations.migration run all -p Tags
EOS
      execute "#{cmd}"
    end
  end

  before 'deploy', 'custom:unlink'
  before 'deploy:symlink:release', 'custom:change_permission'
  before 'deploy:symlink:release', 'custom:install_composer'
  after 'custom:install_composer', 'custom:migrate'
end

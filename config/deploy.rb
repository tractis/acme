set :gateway, "prod1.tractis.com"

set :application, "acme"
set :repository,  "svn+ssh://deployment@svn.negonation.com/tractis/acme"

set :keep_releases, "5"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/apps/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "trapp001", :primary => true
role :app, "trapp002"
role :web, "trapp001","trapp002"

set :user, "deployment"

set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

  desc "Restart the web server"
  task :restart, :roles => :app do
    sudo "touch #{current_path}/tmp/restart.txt"
  end
  
  desc "Normal deployment task"
  task :normal_deploy do
    transaction do
      deploy::update_code
      deploy::symlink
      sec_update_code
    end
  
    restart
    deploy::cleanup
    #deployment:create_svn_tag
  end

  desc "Deployment task for large updates, that need no access from users, the user is redirected to a maintenance page"
  task :long_deploy do
    transaction do
      deploy::update_code
      deploy::web::disable
      deploy::symlink
      sec_update_code
    end
  
    restart
    deploy::web::enable
    deploy::cleanup
    #deployment:create_svn_tag
  end

desc <<DESC
 Security update after the source code in checkout from svn 
 - Update database.yml, set user, passwd and mysql socket 
 - Set owner to gain write permission to webserver user (log and tmp dirs)
DESC
task :sec_update_code, :roles => :app do
  run "rm -f /var/www/apps/acme/current/config/database.yml"
  run "cp /opt/admin/deploy/rails_files/acme_mongrel_cluster.yml /var/www/apps/acme/current/config/mongrel_cluster.yml"
  sudo "chown -R acme:acme /var/www/apps/acme/current/log /var/www/apps/acme/current/tmp"
  # Remove not passenger compatible .htaccess
  run "rm /var/www/apps/acme/current/public/.htaccess"   
  # Tell passenger init cert_mng as user cert_mng
  sudo "chown acme:acme /var/www/apps/acme/current/config/environment.rb"      
end  

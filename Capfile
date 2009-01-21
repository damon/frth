role :web, "codefluency.com"
role :app, "codefluency.com"

set :scm, :git
set :repository, 'git://github.com/bruce/frth.git'

set :user, 'frth'
set :deploy_to, "/var/www/apps/obamaftw"
set :deploy_via, :remote_cache
set :use_sudo, false

load 'deploy' if respond_to?(:namespace) # cap2 differentiator

after "deploy:setup", :create_shared_directories
after "deploy:symlink", :link_shared_directories
after "deploy:symlink", "update_git_submodules"

task :create_shared_directories, :roles => [:app] do  
  run "mkdir -p #{shared_path}/tmp"
  run "mkdir -p #{shared_path}/log"
end  
    
task :update_git_submodules do
  run "cd #{current_path} && brigit update"
end

task :link_shared_directories do
  run "ln -nfs #{shared_path}/tmp #{release_path}/tmp"
  run "ln -nfs #{shared_path}/log #{release_path}/log"
end
  
# Passenger
namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

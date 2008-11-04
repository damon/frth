role :web, "codefluency.com"
role :app, "codefluency.com"

set :scm, :git
set :repository, 'git://github.com/bruce/frth.git'

set :user, 'frth'
set :deploy_to, "/home/#{user}/site"

load 'deploy' if respond_to?(:namespace) # cap2 differentiator

after "deploy:symlink", "deploy:update_git_submodules"
  
namespace :deploy do
  
  task :update_git_submodules do
    run "cd #{current_path} && brigit update"
  end
  
  task :finalize_update, :except => { :no_release => true } do
    run %{
      rm -rf #{latest_release}/log &&
      ln -s #{shared_path}/log #{latest_release}/log
    }
  end
  
  desc "Restart this daemon"
  task :restart, :only => :app, :except => { :no_release => true } do
    stop
    start
  end

  # TODO: Multiple daemons  
  desc "Start this daemon"
  task :start, :roles => :app do
    thin :start
  end
  
  # TODO: Multiple daemons  
  desc "Stop this daemon"
  task :stop, :roles => :app do
    thin :stop
  end

  # Only for rails apps..
  task :migrate do
  end
  
  def thin(command)
    run "thin -s 2 -C config/thin.yml -R config/config.ru #{command}"
  end

end

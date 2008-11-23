require 'yaml'

role :web, "codefluency.com"
role :app, "codefluency.com"

set :scm, :git
set :repository, 'git://github.com/bruce/frth.git'

set :user, 'frth'
set :deploy_to, "/home/#{user}/site"
set :deploy_via, :remote_cache
set :use_sudo, false

load 'deploy' if respond_to?(:namespace) # cap2 differentiator

after "deploy:symlink", "deploy:update_git_submodules"
before "deploy:start", "deploy:write_thin_config"
before "deploy:stop", "deploy:write_thin_config"
  
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
  
  task :write_thin_config do
    config = {
      'environment' => 'production',
      'chdir' => current_path,
      'pid' => "#{shared_path}/pids/thin",
      'log' => "#{shared_path}/log/thin.log",
      'address' => '127.0.0.1',
      'port' => 8900,
      'rackup' => 'config/config.ru',
      'max_conns' => 1024,
      'timeout' => 30,
      'max_persistent_conns' => 512,
      'daemonize' => true
    }.to_yaml
    put config, "#{shared_path}/thin.yml"
  end
  
  def thin(command)
    run "thin -s 2 -C #{shared_path}/thin.yml -R config/config.ru -D -l #{shared_path}/log/sinatra.log #{command}"
  end

end

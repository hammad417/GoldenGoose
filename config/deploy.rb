require "bundle/capistrano"

set :application, "Goose Api"
set :scm, "git"
set :repository, "https://github.com/andrewconrad21/GoldenGoose.git"
set :branch, "master"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

task :production do
  puts "\n\e[0;31m   ######################################################################"
  puts "   #\n   #       Are you REALLY sure you want to deploy to production?"
  puts "   #\n   #               Enter y/N + enter to continue\n   #"
  puts "   ######################################################################\e[0m\n"
  proceed = STDIN.gets[0..0] rescue nil
  exit unless proceed == 'y' || proceed == 'Y'

  set :deploy_via, :remote_cache
  default_run_options[:pty] = true
  ssh_options[:forward_agent] = true
  server "goose.shopvizr.com", :web, :app, :db, :primary => true
  set :stages, %w(staging production)
  set :user, "ec2-user"
  set :deploy_to, "/www/sites/GoldenGoose/"
  set :use_sudo, false
end


namespace :deploy do
  task :bundle, :roles => :app, :except => { :no_release => true } do
    run "cd #{release_path}; #{try_sudo} bundle --deployment;"
  end
  task :add_symlinks, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} ln -Ffs #{File.join(shared_path,'config','database.yml')} #{File.join(release_path,'config','database.yml')}"
    run "#{try_sudo} ln -Ffs #{File.join(shared_path,'vendor','bundle')} #{File.join(release_path,'api','vendor','bundle')}"
  end
  task :clean_assets, :roles => :app, :except => { :no_release => true } do
    run "cd #{release_path}; #{try_sudo} rake assets:clean"
  end
  task :recompile_assets, :roles => :app, :except => { :no_release => true } do
    run "cd #{release_path}; #{try_sudo} rake assets:precompile"
  end
  task :migrate_database, :roles => :db, :except => { :no_release => true } do
    run "cd #{release_path}; #{try_sudo} rake db:migrate"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(release_path,'tmp','restart.txt')}"
  end

end

after 'deploy:update_code', 'deploy:add_symlinks'
after 'deploy:add_symlinks', 'deploy:bundle'
after 'deploy:bundle', 'deploy:clean_assets'
after 'deploy:clean_assets', 'deploy:recompile_assets'
after 'deploy:recompile_assets', 'deploy:migrate_database'
after "deploy:restart", "deploy:cleanup"
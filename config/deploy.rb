# config valid only for current version of Capistrano
lock "3.10.1"

set :application, "auth"
set :repo_url, "git@github.com:diegopiccinini/doorkeeper-provider.git"

set :rvm_type, :system
set :rvm_ruby_version, '2.3.1@rails427'

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, "config/database.yml", "config/secrets.yml", ".env.production", "config/puma.rb"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp", "certs"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :default_env, { 'SECRET_KEY_BASE' => ENV['SECRET_KEY_BASE'], 'SUPPORT_EMAIL' => ENV['SUPPORT_EMAIL'] }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :rails_env, "production"
set :puma_conf, "#{shared_path}/config/puma.rb"

server 'dev01', user: 'bbug', roles: %w{app db web}
set :deploy_to, "/var/www/auth2"
set :puma_conf, "#{shared_path}/config/puma.rb"

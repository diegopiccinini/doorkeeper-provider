class AddApplicationEnvironmentToOauthApplication < ActiveRecord::Migration
  def change
    app_env= ApplicationEnvironment.find_by_name 'Unknown'
    add_reference :oauth_applications, :application_environment, index: true, default: app_env.id
    add_foreign_key :oauth_applications, :application_environments
  end
end

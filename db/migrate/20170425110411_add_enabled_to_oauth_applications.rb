class AddEnabledToOauthApplications < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :enabled, :boolean, default: false
  end
end

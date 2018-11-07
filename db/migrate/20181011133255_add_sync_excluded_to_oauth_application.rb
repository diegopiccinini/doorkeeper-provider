class AddSyncExcludedToOauthApplication < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :sync_excluded, :boolean, default: false
  end
end

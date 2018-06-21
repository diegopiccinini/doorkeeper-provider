class AddStatusIndexToOauthApplicationsSite < ActiveRecord::Migration
  def change
    add_index :oauth_applications_sites, :status
  end
end

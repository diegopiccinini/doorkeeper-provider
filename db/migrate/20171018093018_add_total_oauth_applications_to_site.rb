class AddTotalOauthApplicationsToSite < ActiveRecord::Migration
  def change
    add_column :sites, :total_oauth_applications, :integer, default: 0
  end
end

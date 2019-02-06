class AddTimestampsToOauthApplicationsSites < ActiveRecord::Migration
  def change
    add_column :oauth_applications_sites, :created_at, :datetime, null: false
    add_column :oauth_applications_sites, :updated_at, :datetime, null: false
    OauthApplicationsSite.all.each { |x| x.update( updated_at: x.site.updated_at, created_at: x.site.created_at) }
  end
end

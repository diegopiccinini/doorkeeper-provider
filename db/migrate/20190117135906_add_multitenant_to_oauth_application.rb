class AddMultitenantToOauthApplication < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :multitenant, :boolean, default: false
  end
end

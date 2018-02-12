class AddIndexExternalIdToOauthApplication < ActiveRecord::Migration
  def change
    add_index :oauth_applications, :external_id, unique: true
  end
end

class AddEnabledToEverybodyToOauthApplication < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :enabled_to_everybody, :boolean , default: false, index: true
  end
end

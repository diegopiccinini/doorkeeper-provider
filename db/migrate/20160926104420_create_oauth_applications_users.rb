class CreateOauthApplicationsUsers < ActiveRecord::Migration
  def change
    create_table :oauth_applications_users do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :oauth_application, index: true, foreign_key: true
      t.timestamps null: false
    end
    add_index :oauth_applications_users, [:user_id, :oauth_application_id], unique: true, name: 'users_apps'
  end
end

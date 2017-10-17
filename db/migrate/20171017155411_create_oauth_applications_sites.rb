class CreateOauthApplicationsSites < ActiveRecord::Migration
  def change
    create_table :oauth_applications_sites do |t|
      t.belongs_to :site, index: true, foreign_key: true
      t.belongs_to :oauth_application, index: true, foreign_key: true
      t.string :status
    end
    add_index :oauth_applications_sites, [:site_id, :oauth_application_id], unique: true, name: 'site_application_index'
  end
end

class CreateSiteUser < ActiveRecord::Migration
  def change
    create_join_table :sites, :users do |t|
      t.references :site, foreign_key: true, on_delete: :cascade
      t.references :user, foreign_key: true, on_delete: :cascade
    end
    add_index :sites_users, [:site_id, :user_id], unique: true
  end
end

class AddCascaadeForeignKeysToOauthApplicationsSites < ActiveRecord::Migration

  def up
    remove_foreign_key :oauth_applications_sites, :sites
    remove_foreign_key :oauth_applications_sites, :oauth_applications
    add_foreign_key :oauth_applications_sites, :sites, on_delete: :cascade
    add_foreign_key :oauth_applications_sites, :oauth_applications, on_delete: :cascade
  end

  def down
    remove_foreign_key :oauth_applications_sites, :sites
    remove_foreign_key :oauth_applications_sites, :oauth_applications
    add_foreign_key :oauth_applications_sites, :sites
    add_foreign_key :oauth_applications_sites, :oauth_applications
  end

end

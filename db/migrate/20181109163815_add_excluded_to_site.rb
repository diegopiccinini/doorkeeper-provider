class AddExcludedToSite < ActiveRecord::Migration
  def change
    add_column :sites, :excluded, :boolean, default: false, index: true
  end
end

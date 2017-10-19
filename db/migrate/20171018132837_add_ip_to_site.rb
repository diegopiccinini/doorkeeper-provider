class AddIpToSite < ActiveRecord::Migration
  def change
    add_column :sites, :ip, :string
  end
end

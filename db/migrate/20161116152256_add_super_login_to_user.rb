class AddSuperLoginToUser < ActiveRecord::Migration
  def change
    add_column :users, :super_login, :boolean, default: false
  end
end

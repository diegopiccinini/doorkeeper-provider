class AddExpireAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :expire_at, :datetime
    User.all.each { |u| u.save(validation: false) }
  end
end

class CreateBlackLists < ActiveRecord::Migration
  def change
    create_table :black_lists do |t|
      t.string :url, limit: 255
      t.text :log
      t.integer :times , default: 0

      t.timestamps null: false
    end
    add_index :black_lists, :url, unique: true
  end
end

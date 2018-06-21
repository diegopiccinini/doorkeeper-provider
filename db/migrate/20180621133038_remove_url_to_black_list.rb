class RemoveUrlToBlackList < ActiveRecord::Migration

  def up
    BlackList.delete_all
    remove_index :black_lists, :url
    remove_column :black_lists, :url
    add_reference :black_lists, :site, foreign_key: true, on_delete: :cascade, index: { unique: true }
  end

  def down
    remove_reference :black_lists, :site, foreign_key: true, on_delete: :cascade, index: { unique: true }
    add_column :black_lists, :url, :string, limit: 255
    add_index :black_lists, :url, unique: true
  end
end

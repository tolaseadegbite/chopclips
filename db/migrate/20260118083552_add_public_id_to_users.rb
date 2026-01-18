class AddPublicIdToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :public_id, :string, null: false
    remove_index :users, :public_id if index_exists?(:users, :public_id)
    add_index :users, :public_id, unique: true
  end
end

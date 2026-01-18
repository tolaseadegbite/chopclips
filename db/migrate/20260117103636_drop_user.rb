class DropUser < ActiveRecord::Migration[8.1]
  def change
    drop_table :sessions
    drop_table :events
    drop_table :users
  end
end

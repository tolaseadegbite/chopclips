class CreateAccountsMigration < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts
  end
end

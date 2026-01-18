class MoveUsersToMemberships < ActiveRecord::Migration[8.1]
  def up
    # 1. Create the Join Table
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.string :role, default: "member", null: false # "admin", "editor", "member"

      t.timestamps
    end

    # Ensure unique pairs (User can't join the same team twice)
    add_index :memberships, [ :user_id, :account_id ], unique: true

    # 2. Data Migration: Move existing users to the new table
    # We use raw SQL for speed and to avoid model validation issues during migration
    execute <<-SQL
      INSERT INTO memberships (user_id, account_id, role, created_at, updated_at)
      SELECT id, account_id, 'admin', NOW(), NOW()
      FROM users
    SQL

    # 3. Remove the old column (Breaking the 1:1 chain)
    remove_reference :users, :account
  end

  def down
    add_reference :users, :account, foreign_key: true
    # Data restoration logic would go here if needed
    drop_table :memberships
  end
end

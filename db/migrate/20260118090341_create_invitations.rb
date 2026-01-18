class CreateInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :invitations do |t|
      t.string :email, null: false
      t.references :account, null: false, foreign_key: true
      t.string :role, default: "member", null: false

      # 1. The Stripe-style ID (For Admin UI)
      t.string :public_id, null: false

      # 2. The Secret Token (For the Email Link)
      t.string :token, null: false

      t.datetime :expires_at, null: false
      t.timestamps
    end

    # Indexes
    add_index :invitations, :public_id, unique: true
    add_index :invitations, :token, unique: true

    # Optional: Ensure one email can't be invited to the same account twice
    add_index :invitations, [ :account_id, :email ], unique: true
  end
end

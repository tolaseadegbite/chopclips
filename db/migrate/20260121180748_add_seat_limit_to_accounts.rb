class AddSeatLimitToAccounts < ActiveRecord::Migration[8.1]
  def change
    # Default to 5 seats for the Free plan
    add_column :accounts, :seat_limit, :integer, default: 5, null: false
  end
end

class AddAccountToNoticedNotifications < ActiveRecord::Migration[8.1]
  def change
    add_reference :noticed_notifications, :account, null: false, foreign_key: true
  end
end

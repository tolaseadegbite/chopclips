class AllowNullAccountIdInNoticedNotifications < ActiveRecord::Migration[8.0]
  def change
    # Allow account_id to be NULL to support Global Notifications (like Invitations)
    change_column_null :noticed_notifications, :account_id, true
  end
end

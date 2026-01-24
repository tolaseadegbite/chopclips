class DeliveryMethods::TurboStreamDelivery < Noticed::DeliveryMethod
  def deliver
    # 1. Determine Stream Name
    # Use 'notification.params' instead of 'record.params' for stability in v2
    account_id = notification.params[:account_id]

    stream_name = if account_id.present?
                    "notifications_#{recipient.id}_account_#{account_id}"
    else
                    "notifications_#{recipient.id}_global"
    end

    # 2. Calculate Unread State
    scope = recipient.notifications.unread
    scope = scope.where(account_id: [ account_id, nil ]) if account_id
    has_unread = scope.any?

    # 3. Broadcast Badge (Header & Sidebar)
    [ "header", "sidebar" ].each do |location|
      recipient.broadcast_replace_to(
        stream_name,
        target: "#{location}-notification-badge",
        partial: "notifications/badge",
        locals: { unread: has_unread, id_suffix: location }
      )
    end

    # 4. Broadcast List Item
    # Note: We only target "sidebar" for the list, as the header is just a bell icon
    recipient.broadcast_prepend_to(
      stream_name,
      target: "sidebar-notifications-list",
      partial: "notifications/notification",
      locals: { notification: notification }
    )
  end
end

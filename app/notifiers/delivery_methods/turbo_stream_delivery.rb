class DeliveryMethods::TurboStreamDelivery < Noticed::DeliveryMethod
  def deliver
    # 1. Update Sidebar List
    recipient.broadcast_prepend_to(
      "notifications_#{recipient.id}",
      target: "sidebar-notifications-list",
      partial: "notifications/notification",
      locals: { notification: notification }
    )

    # 2. Update Header List (for Mobile if they are on that page)
    # Note: If you have a specific mobile index page list ID, target that too.
    # Here we assume the header might have a hidden list or similar.
    # If the mobile view is a full page /notifications, target that ID:
    recipient.broadcast_prepend_to(
      "notifications_#{recipient.id}",
      target: "notifications-list", # The ID used in app/views/notifications/index.html.erb
      partial: "notifications/notification",
      locals: { notification: notification }
    )

    # 3. Update Sidebar Badge
    recipient.broadcast_replace_to(
      "notifications_#{recipient.id}",
      target: "sidebar-notification-badge",
      partial: "notifications/badge",
      locals: { unread: true, id_suffix: "sidebar" }
    )

    # 4. Update Header Badge
    recipient.broadcast_replace_to(
      "notifications_#{recipient.id}",
      target: "header-notification-badge",
      partial: "notifications/badge",
      locals: { unread: true, id_suffix: "header" }
    )
  end
end
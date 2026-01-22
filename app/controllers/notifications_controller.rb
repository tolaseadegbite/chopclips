class NotificationsController < ApplicationController
  before_action :authenticate!

  def index
    @notifications = current_user.notifications.newest_first.limit(50)
    # Optional: You could mark all as seen here, but usually mark as read is done individually
  end

  def show
    # Find the specific notification for the current user
    @notification = current_user.notifications.find(params[:id])

    # Mark as read in the database
    @notification.mark_as_read!

    # Redirect to the URL defined in the Notifier subclass (e.g. the acceptance page)
    redirect_to @notification.event.url
  end
end

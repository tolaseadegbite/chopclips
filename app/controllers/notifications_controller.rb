class NotificationsController < ApplicationController
  before_action :authenticate!

  def index
    @notifications = current_user.notifications.newest_first.limit(50)
  end

  def show
    # Standard integer lookup
    @notification = current_user.notifications.find(params[:id])

    @notification.mark_as_read!
    redirect_to @notification.event.url
  end
end

class NotificationsController < DashboardsController
  before_action :authenticate!

  def index
    # KEEP STRICT: Only show notifications relevant to the CURRENT view.
    # We don't want "Workspace A" clutter appearing in "Workspace B" sidebar.
    @notifications = current_user.notifications
                                 .where(account_id: [ Current.account.id, nil ])
                                 .newest_first.limit(50)
  end

  def show
    # RELAX SCOPE: If I own the notification, let me click it.
    # This fixes the "Member Removed" 404, because even though I am in
    # Account 1, I need to be able to "read" the alert from Account 200.
    @notification = current_user.notifications.find(params[:id])

    @notification.mark_as_read!

    # The Helper determines that since I was removed, I go to root_path.
    # If this was a "Task Assigned" in Account 200, and I clicked it from Account 1,
    # the redirect would send me to Account 200, where the 'TasksController'
    # would then handle the security/access check.
    redirect_to helpers.notification_destination(@notification)
  end

  def mark_all_read
    # 1. Strict Scoping: Only unread items for the current user
    scope = current_user.notifications.unread

    # 2. Context Filter: Only mark items visible in the current workspace (plus globals).
    #    This protects the "unread" state of notifications in your OTHER workspaces.
    if Current.account
      scope = scope.where(account_id: [ Current.account.id, nil ])
    end

    # 3. Execution: Single SQL Query
    #    Uses update_all to avoid N+1 queries and memory bloat.
    #    Sets both read_at and seen_at to ensure consistent state.
    scope.update_all(read_at: Time.current, seen_at: Time.current)

    # 4. Response
    #    Redirects back to refresh the UI (clearing the red dots).
    redirect_back(fallback_location: notifications_path, notice: "All notifications marked as read.")
  end
end

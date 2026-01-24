class ApplicationController < ActionController::Base
  # include S3Helper
  # include Pagy::Backend
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  # Make these methods available as helpers in all views
  helper_method :current_user, :user_signed_in?
  helper_method :context_notifications

  # These before_actions run in order on every request
  before_action :set_current_request_details
  before_action :set_current_user_from_session
  before_action :set_current_account
  before_action :authenticate!

  def context_notifications
    # Memoize to prevent multiple DB queries in one request
    @_context_notifications ||= begin
      # 1. Base Scope: The current user
      scope = current_user.notifications

      # 2. Filter: Only this account OR Global (nil)
      #    This prevents "Account 1" events from showing in "Account 2"
      scope = scope.where(account_id: [ Current.account.id, nil ]) if Current.account

      # 3. Sort
      scope.newest_first
    end
  end

  private

  def set_current_user_from_session
    if session_record = Session.find_by_id(cookies.signed[:session_token])
      Current.session = session_record
    end
  end

  def current_user
    Current.user
  end

  def user_signed_in?
    current_user.present?
  end

  def set_current_account
    # We can't set an account if nobody is logged in
    return unless user_signed_in?

    # 1. Check if the user specifically switched to a team (stored in session)
    if session[:current_account_id]
      # Verify they are still a member of that account (Security Check)
      Current.account = current_user.accounts.find_by(id: session[:current_account_id])
    end

    # 2. Fallback: If no preference (or they lost access), default to their first account
    # Usually this is their "Personal Workspace"
    Current.account ||= current_user.accounts.order(created_at: :asc).first
  end

  def authenticate!
    unless user_signed_in?
      redirect_to sign_in_path, alert: "You must be signed in to access this page."
    end
  end

  def set_current_request_details
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
  end

  def require_sudo
    unless Current.session.sudo?
      redirect_to new_sessions_sudo_path(proceed_to_url: request.original_url)
    end
  end
end

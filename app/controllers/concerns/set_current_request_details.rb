module SetCurrentRequestDetails
  extend ActiveSupport::Concern

  included do
    before_action :set_current_account
  end

  private

  def set_current_account
    return unless user_signed_in?

    # 1. Check if Account ID is in the Session (Explicit Switch)
    if session[:current_account_id]
      # Security: Ensure user actually belongs to this account
      Current.account = Current.user.accounts.find_by(id: session[:current_account_id])
    end

    # 2. Fallback: Default to their first account (usually personal workspace)
    Current.account ||= Current.user.accounts.order(created_at: :asc).first

    # 3. Safety: If they have no accounts (weird edge case), make one
    if Current.account.nil?
      Current.user.send(:create_personal_workspace)
      Current.account = Current.user.accounts.first
    end
  end
end

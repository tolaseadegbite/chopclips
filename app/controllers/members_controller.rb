class MembersController < DashboardsController
  before_action :authenticate!

  def index
    # Fetch active members (joined)
    @active_memberships = Current.account.memberships
                                 .includes(:user)
                                 .order(role: :asc, created_at: :desc)

    # Fetch pending invites
    @pending_invitations = Current.account.invitations
                                  .order(created_at: :desc)
  end
end

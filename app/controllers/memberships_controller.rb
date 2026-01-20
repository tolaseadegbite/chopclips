class MembershipsController < DashboardsController
  before_action :authenticate!
  before_action :ensure_admin!

  def destroy
    @membership = Current.account.memberships.find(params[:id])

    if @membership.user == Current.user
      # Case: Leaving the team
      if Current.account.memberships.admin.count == 1
        return redirect_to members_path, alert: "You cannot leave because you are the only Admin. Delete the workspace instead."
      end

      @membership.destroy

      # Clear session and fallback
      session[:current_account_id] = nil
      redirect_to root_path, notice: "You have left #{Current.account.name}."
    else
      # Case: Admin removing someone else
      @membership.destroy
      respond_to do |format|
        format.html { redirect_to members_path, notice: "#{@membership.user.full_name} was removed." }
        format.turbo_stream
      end
    end
  end

  private

  def ensure_admin!
    unless Current.user.memberships.find_by(account: Current.account)&.admin?
      redirect_to members_path, alert: "Only admins can remove members."
    end
  end
end

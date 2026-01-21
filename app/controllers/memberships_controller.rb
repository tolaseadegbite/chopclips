class MembershipsController < DashboardsController
  before_action :authenticate!
  before_action :ensure_admin!

  def update
    @membership = Current.account.memberships.find(params[:id])
    new_role = membership_params[:role]

    # Guard Clause: Last Admin Check
    if @membership.admin? && new_role == "member" && Current.account.memberships.admin.count <= 1
      # Fix 1: Use flash.now for the error
      flash.now[:alert] = "You cannot demote the only Admin. Promote someone else first."

      # Fix 2: Pass @membership directly (no dom_id needed)
      # Fix 3: Send an array of streams to update BOTH the row (reset logic) AND the flash (show error)
      render turbo_stream: [
        turbo_stream.replace(@membership, partial: "members/membership", locals: { membership: @membership }),
        turbo_stream.update("flash", partial: "layouts/shared/flash")
      ]
      return
    end

    if @membership.update(role: new_role)
      if @membership.saved_change_to_role?
        # MembershipMailer.with(membership: @membership).role_changed.deliver_later
      end

      respond_to do |format|
        format.html { redirect_to members_path, notice: "Role updated." }
        format.turbo_stream { flash.now[:notice] = "Role updated successfully." }
      end
    else
      redirect_to members_path, alert: "Unable to update role."
    end
  end

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
        format.turbo_stream { flash.now[:notice] = "#{@membership.user.full_name} was removed." }
      end
    end
  end

  private

  def ensure_admin!
    unless Current.user.memberships.find_by(account: Current.account)&.admin?
      redirect_to members_path, alert: "Only admins can remove members."
    end
  end

  def membership_params
    params.require(:membership).permit(:role)
  end
end

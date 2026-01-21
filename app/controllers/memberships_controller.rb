class MembershipsController < DashboardsController
  before_action :authenticate!

  # Only Admins can update roles
  before_action :ensure_admin!, only: [ :update ]

  def update
    @membership = Current.account.memberships.find(params[:id])
    new_role = membership_params[:role]

    # Guard Clause: Prevent the last admin from demoting themselves
    if @membership.admin? && new_role == "member" && Current.account.memberships.admin.count <= 1
      flash.now[:alert] = "You cannot demote the only Admin. Promote someone else first."

      render turbo_stream: [
        turbo_stream.replace(@membership, partial: "members/membership", locals: { membership: @membership }),
        turbo_stream.update("flash_messages", partial: "layouts/shared/flash")
      ]
      return
    end

    if @membership.update(role: new_role)
      if @membership.saved_change_to_role?
        MembershipMailer.with(membership: @membership).role_changed.deliver_later
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

    # AUTHORIZATION CHECK
    # Allow if: You are an Admin OR You are removing yourself
    unless current_user_admin? || @membership.user == Current.user
      redirect_to members_path, alert: "You do not have permission to do that."
      return
    end

    if @membership.user == Current.user
      # --- CASE 1: LEAVING (Self-removal) ---

      # Safety Check: Last Admin cannot leave
      if @membership.admin? && Current.account.memberships.admin.count == 1
        redirect_to members_path, alert: "You cannot leave because you are the only Admin."
        return
      end

      @membership.destroy

      # Important: Log them out of this specific scope immediately
      session[:current_account_id] = nil
      redirect_to root_path, notice: "You have left #{Current.account.name}."
    else
      # --- CASE 2: KICKED (Admin removing someone else) ---

      user_to_remove = @membership.user
      account_context = @membership.account

      @membership.destroy

      # Send Notification
      MembershipMailer.with(user: user_to_remove, account: account_context).removed.deliver_later

      respond_to do |format|
        format.html { redirect_to members_path, notice: "#{user_to_remove.full_name} was removed." }
        format.turbo_stream { flash.now[:notice] = "#{user_to_remove.full_name} was removed." }
      end
    end
  end

  private

  def current_user_admin?
    Current.user.memberships.find_by(account: Current.account)&.admin?
  end

  def ensure_admin!
    unless current_user_admin?
      redirect_to members_path, alert: "Only admins can perform this action."
    end
  end

  def membership_params
    params.require(:membership).permit(:role)
  end
end

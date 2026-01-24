class MembershipsController < DashboardsController
  before_action :authenticate!
  before_action :ensure_admin!, only: [ :update ]

  def update
    @membership = Current.account.memberships.find(params[:id])
    new_role = membership_params[:role]

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

        # 1. Notify the person whose role changed
        RoleChangedNotifier.with(
          account_id: Current.account.id,
          account_name: Current.account.name,
          user_id: @membership.user_id,
          user_name: @membership.user.full_name,
          role: new_role
        ).deliver_later(@membership.user)

        # 2. Notify other Admins
        other_admins = Current.account.memberships.admin
                                      .includes(:user)
                                      .where.not(user_id: [ @membership.user_id, Current.user.id ])
                                      .map(&:user)

        other_admins.each do |admin|
          RoleChangedNotifier.with(
            account_id: Current.account.id,
            account_name: Current.account.name,
            user_id: @membership.user_id,
            user_name: @membership.user.full_name,
            role: new_role
          ).deliver_later(admin)
        end
      end

      respond_to do |format|
        format.html { redirect_to members_path, notice: "Role updated." }
        format.turbo_stream { flash.now[:notice] = "Role updated successfully." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @membership = Current.account.memberships.find(params[:id])

    unless current_user_admin? || @membership.user == Current.user
      redirect_to members_path, alert: "You do not have permission to do that."
      return
    end

    if @membership.user == Current.user
      # --- CASE 1: LEAVING (Self-removal) ---
      if @membership.admin? && Current.account.memberships.admin.count == 1
        redirect_to members_path, alert: "You cannot leave because you are the only Admin. Delete the workspace instead."
        return
      end

      user_who_left = @membership.user
      account_context = @membership.account

      admins_to_notify = account_context.memberships.admin
                                        .includes(:user)
                                        .where.not(user_id: user_who_left.id)
                                        .map(&:user)

      @membership.destroy

      admins_to_notify.each do |admin|
        MembershipMailer.with(admin: admin, user: user_who_left, account: account_context).member_left.deliver_later

        # In-App Notification to Admins: "Bob has left..."
        MemberLeftNotifier.with(
          account_id: account_context.id,
          user_name: user_who_left.full_name,
          account_name: account_context.name
        ).deliver_later(admin)
      end

      session[:current_account_id] = nil
      redirect_to root_path, notice: "You have left #{account_context.name}."

    else
      # --- CASE 2: KICKED (Admin removing someone else) ---
      user_to_remove = @membership.user
      account_context = @membership.account

      # Find other admins to notify (excluding the one doing the removing and the one being removed)
      other_admins = account_context.memberships.admin
                                    .includes(:user)
                                    .where.not(user_id: [ user_to_remove.id, Current.user.id ])
                                    .map(&:user)

      @membership.destroy

      # 1. Email to the removed user
      MembershipMailer.with(user: user_to_remove, account: account_context).removed.deliver_later

      # 2. In-App to the removed user (for history/audit)
      MemberRemovedNotifier.with(
        account_id: account_context.id,
        account_name: account_context.name,
        user_id: user_to_remove.id # Used to detect "Your role" vs "User's role"
      ).deliver_later(user_to_remove)

      # 3. In-App to other Admins: "Bob was removed by Tolase"
      other_admins.each do |admin|
        MemberRemovedNotifier.with(
          account_id: account_context.id,
          account_name: account_context.name,
          user_id: user_to_remove.id,
          user_name: user_to_remove.full_name,
          actor_name: Current.user.full_name
        ).deliver_later(admin)
      end

      respond_to do |format|
        format.html { redirect_to members_path, notice: "#{user_to_remove.full_name} was removed from the team." }
        format.turbo_stream { flash.now[:notice] = "#{user_to_remove.full_name} was removed from the team." }
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

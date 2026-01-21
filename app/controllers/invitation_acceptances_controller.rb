class InvitationAcceptancesController < ApplicationController
  skip_before_action :authenticate!
  before_action :find_invitation

  def show
    if user_signed_in?
      # Security Check: Ensure the logged-in user matches the invite
      unless Current.user.email.downcase == @invitation.email.downcase
        render :wrong_user
      end
    else
      @user = User.new(email: @invitation.email)
    end
  end

  def update
    if user_signed_in?
      # Scenario A: Logged In User clicked "Join Team"
      accept_invitation(Current.user)
    else
      # Scenario B: New User filled out the Registration Form
      @user = User.new(user_params)
      @user.email = @invitation.email
      @user.verified = true

      if @user.save
        accept_invitation(@user)
      else
        render :show, status: :unprocessable_entity
      end
    end
  end

  private

  def find_invitation
    @invitation = Invitation.find_by(token: params[:token])

    # 1. Check if it exists
    if @invitation.nil?
      redirect_to root_path, alert: "Invalid invitation link."
      return
    end

    # 2. Check if it is expired
    if @invitation.expired?
      redirect_to root_path, alert: "This invitation has expired. Please ask the admin to resend it."
      nil # Use return here, not nil
    end
  end

  def accept_invitation(user)
    # 1. Capture the account before destroying the invite to avoid association errors
    account_to_join = @invitation.account
    role_assigned = @invitation.role

    ActiveRecord::Base.transaction do
      Membership.create!(
        user: user,
        account: account_to_join,
        role: role_assigned
      )
      @invitation.destroy!
    end

    # 2. Notify Admins
    # Find all admins of the account we just joined
    admins_to_notify = account_to_join.memberships.admin.includes(:user).map(&:user)

    admins_to_notify.each do |admin|
      MembershipMailer.with(
        admin: admin,
        new_member: user,
        account: account_to_join
      ).member_joined.deliver_later
    end

    # 3. Log in and switch context
    session[:user_id] = user.id
    session[:current_account_id] = account_to_join.id

    redirect_to root_path, notice: "You have joined #{account_to_join.name}!"
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :password, :password_confirmation)
  end
end

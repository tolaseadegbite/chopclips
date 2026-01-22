class InvitationAcceptancesController < ApplicationController
  skip_before_action :authenticate!
  before_action :find_invitation

  def show
    if user_signed_in?
      unless Current.user.email.downcase == @invitation.email.downcase
        render :wrong_user
      end
    else
      @user = User.new(email: @invitation.email)
    end
  end

  def update
    if user_signed_in?
      accept_invitation(Current.user)
    else
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

    if @invitation.nil?
      redirect_to root_path, alert: "Invalid invitation link."
      return
    end

    if @invitation.expired?
      redirect_to root_path, alert: "This invitation has expired. Please ask the admin to resend it."
      nil # FIXED: Changed from nil to return
    end
  end

  def accept_invitation(user)
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

    admins_to_notify = account_to_join.memberships.admin.includes(:user).map(&:user)

    admins_to_notify.each do |admin|
      # 1. Email
      MembershipMailer.with(
        admin: admin,
        new_member: user,
        account: account_to_join
      ).member_joined.deliver_later

      # 2. In-App Notification
      MemberJoinedNotifier.with(
        user_name: user.full_name,
        account_name: account_to_join.name
      ).deliver_later(admin)
    end

    session[:user_id] = user.id
    session[:current_account_id] = account_to_join.id

    redirect_to root_path, notice: "You have joined #{account_to_join.name}!"
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :password, :password_confirmation)
  end
end

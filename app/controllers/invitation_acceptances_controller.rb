class InvitationAcceptancesController < ApplicationController
  skip_before_action :authenticate!
  before_action :find_invitation

  def show
    if user_signed_in?
      # Security Check: Ensure the logged-in user matches the invite
      unless Current.user.email.downcase == @invitation.email.downcase
        # Log out the wrong user so the correct person can sign in
        # Or render a specific error page
        render :wrong_user
      end
      # If emails match, we just fall through to render 'show.html.erb'
      # This lets the user see the "Join Team" button.
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
    redirect_to root_path, alert: "Invalid invitation." unless @invitation
  end

  def accept_invitation(user)
    ActiveRecord::Base.transaction do
      Membership.create!(
        user: user,
        account: @invitation.account,
        role: @invitation.role
      )
      @invitation.destroy!
    end

    # Ensure session is set correctly
    session[:user_id] = user.id
    session[:current_account_id] = @invitation.account.id

    redirect_to root_path, notice: "You have joined #{@invitation.account.name}!"
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :password, :password_confirmation)
  end
end

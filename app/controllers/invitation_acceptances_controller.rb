class InvitationAcceptancesController < ApplicationController
  skip_before_action :authenticate!
  before_action :find_invitation

  def show
    if user_signed_in?
      if Current.user.email.downcase == @invitation.email.downcase
        accept_invitation(Current.user)
      else
        # Render a view saying "You are logged in as X, but invite is for Y"
        render :wrong_user
      end
    else
      @user = User.new(email: @invitation.email)
    end
  end

  def update
    @user = User.new(user_params)
    @user.email = @invitation.email
    @user.verified = true

    if @user.save
      accept_invitation(@user)
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def find_invitation
    @invitation = Invitation.find_by(token: params[:token])
    redirect_to root_path, alert: "Invalid invitation." unless @invitation
  end

  def accept_invitation(user)
    ActiveRecord::Base.transaction do
      # THIS IS THE KEY CHANGE: Create Membership, don't update User
      Membership.create!(
        user: user,
        account: @invitation.account,
        role: @invitation.role
      )
      @invitation.destroy!
    end

    # Log in and switch context to the new team
    session[:user_id] = user.id
    session[:current_account_id] = @invitation.account.id

    redirect_to root_path, notice: "Joined #{@invitation.account.name}!"
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :password, :password_confirmation)
  end
end

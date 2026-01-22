class InvitationsController < ApplicationController
  before_action :authenticate!
  before_action :set_invitation, only: [ :destroy, :resend ]

  def new
    @invitation = Invitation.new
  end

  def create
    if Current.account.seat_limit_reached?
      message = "You have reached your seat limit of #{Current.account.seat_limit}. Please upgrade to invite more members."

      respond_to do |format|
        format.html { redirect_to members_path, alert: message }
        format.turbo_stream do
          flash.now[:alert] = message
          render turbo_stream: turbo_stream.update("flash_messages", partial: "layouts/shared/flash")
        end
      end
      return
    end

    @invitation = Current.account.invitations.new(invitation_params)

    if @invitation.save
      # 1. Always send the Email (The bridge)
      InvitationMailer.with(invitation: @invitation).invite.deliver_later

      # 2. Logic for Existing Users (The in-app magic)
      # We lowercase the email for a robust lookup
      if existing_user = User.find_by(email: @invitation.email.downcase)
        InvitationReceivedNotifier.with(
          account_name: Current.account.name,
          token: @invitation.token
        ).deliver_later(existing_user)
      end

      respond_to do |format|
        format.html { redirect_to members_path, notice: "Invitation sent successfully." }
        format.turbo_stream { flash.now[:notice] = "Invitation sent successfully." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def resend
    # 2. Guard: Rate Limiting (5-minute cooldown)
    if @invitation.updated_at > 5.minutes.ago
      flash.now[:alert] = "Please wait a few minutes before resending."
      render turbo_stream: turbo_stream.update("flash_messages", partial: "layouts/shared/flash")
      return
    end

    ActiveRecord::Base.transaction do
      # Renew expiration (2 days from NOW)
      @invitation.update!(expires_at: 2.days.from_now)

      # Update 'updated_at' to reset the rate limit timer and update UI
      @invitation.touch
    end

    InvitationMailer.with(invitation: @invitation).invite.deliver_later

    respond_to do |format|
      format.html { redirect_to members_path, notice: "Invitation resent." }
      format.turbo_stream { flash.now[:notice] = "Invitation resent to #{@invitation.email}." }
    end
  end

  def destroy
    @invitation.destroy

    respond_to do |format|
      format.html { redirect_to members_path, notice: "Invitation revoked." }
      format.turbo_stream { flash.now[:notice] = "Invitation revoked." }
    end
  end

  private

  def set_invitation
    @invitation = Current.account.invitations.find_by_public_id!(params[:id])
  end

  def invitation_params
    params.require(:invitation).permit(:email, :role)
  end
end

class InvitationsController < ApplicationController
  before_action :authenticate!

  def new
    @invitation = Invitation.new
  end

  def create
    @invitation = Current.account.invitations.new(invitation_params)

    if @invitation.save
      InvitationMailer.with(invitation: @invitation).invite.deliver_later
      respond_to do |format|
        format.html { redirect_to members_path, notice: "Invitation sent successfully." }
        format.turbo_stream { flash.now[:notice] = "Invitation sent successfully." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @invitation = Current.account.invitations.find_by_public_id!(params[:id])
    @invitation.destroy

    respond_to do |format|
      format.html { redirect_to members_path, notice: "Invitation revoked." }
      format.turbo_stream { flash.now[:notice] = "Invitation revoked." }
    end
  end

  def resend
    @invitation = Current.account.invitations.find_by_public_id!(params[:id])

    # Rate Limiting: Prevent spamming (5-minute cooldown)
    # if @invitation.updated_at > 5.minutes.ago
    #   flash.now[:alert] = "Please wait a few minutes before resending."
    #   render turbo_stream
    #   return
    # end

    ActiveRecord::Base.transaction do
      # 1. Renew expiration (2 days from NOW)
      @invitation.update!(expires_at: 2.days.from_now)

      # 2. Update 'updated_at' so the UI reflects recent activity
      @invitation.touch
    end

    # 3. Send Email
    InvitationMailer.with(invitation: @invitation).invite.deliver_later

    respond_to do |format|
      format.html { redirect_to members_path, notice: "Invitation resent." }
      format.turbo_stream { flash.now[:notice] = "Invitation resent to #{@invitation.email}." }
    end
  end

  private

  def invitation_params
    params.require(:invitation).permit(:email, :role)
  end
end

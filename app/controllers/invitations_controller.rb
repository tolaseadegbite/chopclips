class InvitationsController < ApplicationController
  before_action :authenticate!

  def create
    # Use Current.account to ensure invite comes from the active workspace
    @invitation = Current.account.invitations.new(invitation_params)

    if @invitation.save
      InvitationMailer.with(invitation: @invitation).invite.deliver_later
      redirect_to members_path, notice: "Invitation sent."
    else
      redirect_to members_path, alert: "Could not send invite: #{@invitation.errors.full_messages.to_sentence}"
    end
  end

  def destroy
    @invitation = Current.account.invitations.find_by_public_id!(params[:id])
    @invitation.destroy
    redirect_to members_path, notice: "Invitation revoked."
  end

  private

  def invitation_params
    params.require(:invitation).permit(:email, :role)
  end
end

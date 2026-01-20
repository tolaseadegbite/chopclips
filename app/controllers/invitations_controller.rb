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
        format.html { redirect_to members_path, notice: "Invitation sent." }
        format.turbo_stream
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
      format.turbo_stream
    end
  end

  private

  def invitation_params
    params.require(:invitation).permit(:email, :role)
  end
end

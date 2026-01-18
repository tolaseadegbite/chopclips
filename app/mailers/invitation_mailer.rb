class InvitationMailer < ApplicationMailer
  def invite
    @invitation = params[:invitation]
    @account = @invitation.account

    mail(
      to: @invitation.email,
      subject: "You've been invited to join #{@account.name} on ChopClips"
    )
  end
end

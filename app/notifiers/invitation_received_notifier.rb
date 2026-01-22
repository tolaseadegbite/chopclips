class InvitationReceivedNotifier < TeamNotifier
  def message
    "You have been invited to join #{params[:account_name]}."
  end

  # The URL Bob clicks in his notification list
  def url
    Rails.application.routes.url_helpers.invitation_acceptance_url(token: params[:token])
  end
end

class TeamNotifier < Noticed::Event
  deliver_by :turbo_stream, class: "DeliveryMethods::TurboStreamDelivery"

  def recipient_attributes_for(recipient)
    # FIX: Call super first to get recipient_type and recipient_id,
    # then merge in your custom account_id.
    super.merge(account_id: params[:account_id])
  end

  def url
    Rails.application.routes.url_helpers.members_path
  end
end

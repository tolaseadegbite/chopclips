class TeamNotifier < Noticed::Event
  # 1. Database Delivery (Audit trail & History)
  deliver_by :database

  # 2. Turbo Stream Delivery (Real-time UI updates)
  deliver_by :turbo_stream, class: "DeliveryMethods::TurboStreamDelivery"

  # Helpers
  def message
    raise NotImplementedError
  end

  def url
    Rails.application.routes.url_helpers.members_path
  end
end

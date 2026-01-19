class Authentications::EventsController < DashboardsController
  def index
    @events = Current.user.events.order(created_at: :desc)
  end
end

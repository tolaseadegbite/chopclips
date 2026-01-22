class MemberRemovedNotifier < TeamNotifier
  def message
    "You have been removed from #{params[:account_name]}."
  end

  # Override the default URL because they can no longer access the members page of that team
  def url
    Rails.application.routes.url_helpers.root_path
  end
end

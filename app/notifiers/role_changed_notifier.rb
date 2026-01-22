class RoleChangedNotifier < TeamNotifier
  def message
    "Your role in #{params[:account_name]} was changed to #{params[:role].humanize}."
  end
end

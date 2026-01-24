class MemberRemovedNotifier < TeamNotifier
  # def message
  #   if recipient.id == params[:user_id]
  #     "You have been removed from #{params[:account_name]}."
  #   else
  #     "#{params[:user_name]} was removed from the team by #{params[:actor_name]}."
  #   end
  # end

  # def url
  #   # Removed users shouldn't link to the members page they can't see
  #   recipient.id == params[:user_id] ? Rails.application.routes.url_helpers.root_path : super
  # end
end

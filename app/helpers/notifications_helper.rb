module NotificationsHelper
  def notification_message(notification)
    event = notification.event
    params = event.params
    recipient = notification.recipient

    case event.type
    when "RoleChangedNotifier"
      if recipient.id == params[:user_id]
        "Your role in #{params[:account_name]} was changed to #{params[:role].humanize}."
      else
        "#{params[:user_name]}'s role was changed to #{params[:role].humanize}."
      end

    when "MemberRemovedNotifier"
      if recipient.id == params[:user_id]
        "You have been removed from #{params[:account_name]}."
      else
        "#{params[:user_name]} was removed from the team by #{params[:actor_name]}."
      end

    when "MemberLeftNotifier"
      "#{params[:user_name]} has left #{params[:account_name]}."

    when "MemberJoinedNotifier"
      "#{params[:user_name]} has joined #{params[:account_name]}."

    when "InvitationReceivedNotifier"
      "You have been invited to join #{params[:account_name]}."

    else
      "New Notification"
    end
  end

  def notification_destination(notification)
    event = notification.event
    params = event.params
    recipient = notification.recipient

    case event.type
    when "MemberRemovedNotifier"
      # If I am the person who was removed, I can't go to the team page anymore.
      if recipient.id == params[:user_id]
        root_path
      else
        # I am an Admin, go to the team list to see the aftermath
        members_path
      end

    when "InvitationReceivedNotifier"
      # Use the specific route helper for the token
      invitation_acceptance_path(token: params[:token])

    else
      # Default fallback for everything else (Members, Roles, etc)
      # This relies on the 'url' method in TeamNotifier defaulting to members_path
      event.url rescue root_path
    end
  end

  def notification_avatar_initials(notification)
    params = notification.event.params
    if params[:user_name].present?
      # Show User Initials (e.g. for joins, roles, leaves)
      params[:user_name].split.first(2).map(&:first).join.upcase
    else
      # Show Workspace Initials (e.g. for invitations)
      account_initials(notification.account)
    end
  end

  def notification_avatar_style(notification)
    # Circle for people actions, Square for workspace actions
    notification.event.params[:user_name].present? ? "rounded-full bg-teal-600" : "rounded-md bg-black"
  end
end

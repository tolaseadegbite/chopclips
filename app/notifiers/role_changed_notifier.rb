class RoleChangedNotifier < TeamNotifier
  def message
    # ERROR: 'recipient' is not available here on the Event object
    # if recipient.id == params[:user_id]

    # FIX: We need to change the logic.
    # Since the message depends on WHO sees it ("Your role" vs "Bob's role"),
    # we cannot have a single static message on the Event.
    # We must move this logic to a Helper or accept the recipient as an argument.

    raise "Use helper method instead"
  end
end

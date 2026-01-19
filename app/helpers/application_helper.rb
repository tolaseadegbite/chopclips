module ApplicationHelper
  include Pagy::Frontend

  def full_title(page_title = "")
    base_title = "ChopClips"
    if page_title.blank?
        base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  # Generates "TW" from "Tolase's Workspace"
  def account_initials(account)
    return "?" unless account&.name

    # Logic: Take first letter of first two words, upcased
    # "Red Bull Media" -> "RB"
    # "Tolase" -> "T"
    account.name.split.first(2).map(&:first).join.upcase
  end

  # Returns the role of the current user in the current workspace
  def current_role
    return "" unless Current.user && Current.account

    # Memoize this to avoid hitting DB multiple times
    @current_role ||= Current.user.memberships
                        .find_by(account: Current.account)
                        &.role
                        &.humanize || "Member"
  end
end

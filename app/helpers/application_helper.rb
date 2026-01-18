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
end

class StaticPagesController < ApplicationController
  def homepage
    if user_signed_in?
      redirect_to home_index_path
    end
  end

  def pricing
  end

  def privacy
  end

  def support
  end

  def tos
  end

  def privacy_policy
  end
end

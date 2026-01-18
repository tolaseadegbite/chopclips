class AccountsController < ApplicationController
  before_action :authenticate!

  # GET /accounts/switch/:id
  def switch
    # Find account via Public ID, ensuring the user is a member
    target_account = Current.user.accounts.find_by_public_id!(params[:id])

    # Save to session
    session[:current_account_id] = target_account.id

    redirect_back fallback_location: root_path, notice: "Switched to #{target_account.name}"
  end
end

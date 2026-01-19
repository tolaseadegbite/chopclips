class AccountsController < ApplicationController
  before_action :authenticate

  def new
    @account = Account.new
  end

  def create
    @account = Account.new(account_params)

    ActiveRecord::Base.transaction do
      # 1. Save the Account
      @account.save!

      # 2. Force the Creator to be an Admin
      Membership.create!(
        user: Current.user,
        account: @account,
        role: :admin
      )
    end

    # Switch context to the new account immediately
    session[:current_account_id] = @account.id

    redirect_to root_path, notice: "Workspace '#{@account.name}' created!"

  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

    def switch
      # Find account via Public ID, ensuring the user is a member
      target_account = Current.user.accounts.find_by_public_id!(params[:id])

      # Save to session
      session[:current_account_id] = target_account.id

      redirect_back fallback_location: root_path, notice: "Switched to #{target_account.name}"
    end

  private

  def account_params
    params.require(:account).permit(:name)
  end
end

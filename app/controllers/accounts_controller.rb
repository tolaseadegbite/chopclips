class AccountsController < DashboardsController
  before_action :authenticate!
  before_action :ensure_admin!, only: [ :edit, :update, :destroy ]

  def new
    @account = Account.new
  end

  def create
    @account = Account.new(account_params)

    ActiveRecord::Base.transaction do
      @account.save!
      Membership.create!(user: Current.user, account: @account, role: :admin)
    end

    session[:current_account_id] = @account.id
    redirect_to root_path, notice: "Workspace '#{@account.name}' created!"
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  # GET /accounts/:id/edit
  def edit
    # We ignore params[:id] for security and just edit the current context
    # or ensure params[:id] matches Current.account.id
    @account = Current.account
  end

  def update
    @account = Current.account

    if @account.update(account_params)
      redirect_to edit_account_path(@account), notice: "Workspace updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @account = Current.account

    if Current.user.accounts.count == 1
      redirect_to edit_account_path(@account), alert: "You cannot delete your personal workspace."
      return
    end

    @account.destroy

    # Reset session and fallback
    session[:current_account_id] = nil
    redirect_to root_path, notice: "Workspace deleted."
  end

  def switch
    target_account = Current.user.accounts.find_by_public_id!(params[:id])
    session[:current_account_id] = target_account.id
    redirect_back fallback_location: root_path, notice: "Switched to #{target_account.name}"
  end

  private

  def ensure_admin!
    # Double check: Current.account must match the one in params if passed,
    # OR we just operate on Current.account.
    unless Current.user.memberships.find_by(account: Current.account)&.admin?
      redirect_to root_path, alert: "Access denied. Admins only."
    end
  end

  def account_params
    params.require(:account).permit(:name)
  end
end

class MembershipMailer < ApplicationMailer
  def role_changed
    @membership = params[:membership]
    @account = @membership.account
    @user = @membership.user

    mail(
      to: @user.email,
      subject: "Your role in #{@account.name} has been updated"
    )
  end
end

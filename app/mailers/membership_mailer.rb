class MembershipMailer < ApplicationMailer
  def member_joined
    @admin = params[:admin]         # The recipient (Account Owner)
    @new_member = params[:new_member] # Bob
    @account = params[:account]

    mail(
      to: @admin.email,
      subject: "#{@new_member.full_name} has joined #{@account.name}"
    )
  end

  def role_changed
    @membership = params[:membership]
    @account = @membership.account
    @user = @membership.user

    mail(
      to: @user.email,
      subject: "Your role in #{@account.name} has been updated"
    )
  end

  def removed
    @user = params[:user]
    @account = params[:account]

    mail(
      to: @user.email,
      subject: "You have been removed from #{@account.name}"
    )
  end

  def member_left
    @admin = params[:admin]   # The recipient
    @user = params[:user]     # The person who left
    @account = params[:account]

    mail(
      to: @admin.email,
      subject: "#{@user.full_name} has left #{@account.name}"
    )
  end
end

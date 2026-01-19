# class Identity::EmailVerificationsController < ApplicationController
#   skip_before_action :authenticate, only: :show

#   before_action :set_user, only: :show

#   def show
#     @user.update! verified: true
#     redirect_to root_path, notice: "Thank you for verifying your email address"
#   end

#   def create
#     send_email_verification
#     redirect_to root_path, notice: "We sent a verification email to your email address"
#   end

#   private
#     def set_user
#       @user = User.find_by_token_for!(:email_verification, params[:sid])
#     rescue StandardError
#       redirect_to edit_identity_email_path, alert: "That email verification link is invalid"
#     end

#     def send_email_verification
#       UserMailer.with(user: Current.user).email_verification.deliver_later
#     end
# end

class Identity::EmailVerificationsController < ApplicationController
  skip_before_action :authenticate, only: :show

  before_action :set_user, only: :show

  def show
    @user.update! verified: true
    redirect_to root_path, notice: "Thank you for verifying your email address"
  end

  # def create
  #   send_email_verification
  #   redirect_to root_path, notice: "We sent a verification email to your email address"
  # end

  def create
    send_email_verification

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = "We sent another verification email to your address."
        render turbo_stream: turbo_stream.update("flash_messages", partial: "layouts/shared/flash")
      end

      format.html do
        redirect_to root_path, notice: "We sent a verification email to your email address"
      end
    end
  end

  private
    def set_user
      @user = User.find_by_token_for!(:email_verification, params[:sid])
    rescue StandardError
      redirect_to edit_identity_email_path, alert: "That email verification link is invalid"
    end

    def send_email_verification
      UserMailer.with(user: Current.user).email_verification.deliver_later
    end
end

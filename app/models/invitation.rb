class Invitation < ApplicationRecord
  include PublicIdentifiable
  has_public_id prefix: "inv"

  has_secure_token :token

  before_create :set_expiration

  belongs_to :account

  # Secure token for the email link (separate from public_id)
  has_secure_token

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Ensure an email can't be invited twice to the same account
  validates :email, uniqueness: { scope: :account_id, message: "has already been invited" }

  # Don't invite someone who is already a member
  validate :email_not_already_member

  def expired?
    expires_at < Time.current
  end

  private

  def set_expiration
    # Default to 48 hours from creation
    self.expires_at = 2.days.from_now
  end

  def email_not_already_member
    if account.users.exists?(email: email)
      errors.add(:email, "is already a member of this workspace")
    end
  end
end

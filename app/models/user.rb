class User < ApplicationRecord
  include PublicIdentifiable
  has_public_id prefix: "user"

  has_secure_password

  # OLD: belongs_to :account
  # NEW: Can have many teams
  has_many :memberships, dependent: :destroy
  has_many :accounts, through: :memberships

  generates_token_for :email_verification, expires_in: 2.days do
    email
  end

  generates_token_for :password_reset, expires_in: 20.minutes do
    password_salt.last(10)
  end

  has_many :sessions, dependent: :destroy
  has_many :sign_in_tokens, dependent: :destroy
  has_many :events, dependent: :destroy

  # Note: Projects/Clips still belong to user for "Created By" history,
  # but access control is now done via Account.
  has_many :projects, dependent: :destroy
  has_many :clips, dependent: :destroy

  validates :first_name, :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, allow_nil: true, length: { minimum: 12 }
  validates :password, not_pwned: { message: "might easily be guessed" }

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def initials
    "#{first_name&.first}#{last_name&.first}".upcase
  end

  normalizes :email, with: -> { _1.strip.downcase }

  before_validation if: :email_changed?, on: :update do
    self.verified = false
  end

  after_update if: :password_digest_previously_changed? do
    sessions.where.not(id: Current.session).delete_all
  end

  after_update if: :email_previously_changed? do
    events.create! action: "email_verification_requested"
  end

  after_update if: :password_digest_previously_changed? do
    events.create! action: "password_changed"
  end

  after_update if: [ :verified_previously_changed?, :verified? ] do
    events.create! action: "email_verified"
  end

  # UPDATED: Onboarding Logic
  # We no longer set self.account = ...
  # We create a membership after the user is persisted.
  after_create :create_personal_workspace

  private

  def create_personal_workspace
    # Only create a workspace if they didn't join via an invite
    return if memberships.any?

    transaction do
      personal_account = Account.create!(name: "#{first_name}'s Workspace")
      memberships.create!(account: personal_account, role: "admin")
    end
  end
end

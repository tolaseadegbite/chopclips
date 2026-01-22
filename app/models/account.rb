class Account < ApplicationRecord
  include PublicIdentifiable
  has_public_id prefix: "acct"

  # OLD: has_many :users
  # NEW: Connected via membership
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  has_many :invitations, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :clips, dependent: :destroy

  has_many :noticed_events, as: :record, dependent: :destroy, class_name: "Noticed::Event"
  has_many :notifications, through: :noticed_events, class_name: "Noticed::Notification"

  validates :name, presence: true

  def personal?
    # Simple logic: If it's the user's oldest account and they are the only member
    # Or explicit logic if you added a `personal: boolean` column.
    # For now, simplest is:
    memberships.count == 1 && memberships.first.admin?
  end

  def seats_used
    memberships.count + invitations.count
  end

  def seat_limit_reached?
    seats_used >= seat_limit
  end

  def seats_available
    seat_limit - seats_used
  end
end

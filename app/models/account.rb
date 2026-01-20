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

  validates :name, presence: true

  def personal?
    # Simple logic: If it's the user's oldest account and they are the only member
    # Or explicit logic if you added a `personal: boolean` column.
    # For now, simplest is:
    memberships.count == 1 && memberships.first.admin?
  end
end

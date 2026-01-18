class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :account

  # Simple Role Logic (Can be expanded to a full Pundit policy later)
  enum :role, { member: "member", admin: "admin" }, default: :member

  validates :user_id, uniqueness: { scope: :account_id }
end

class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :account

  has_many :noticed_events, as: :record, dependent: :destroy, class_name: "Noticed::Event"
  has_many :notifications, through: :noticed_events, class_name: "Noticed::Notification"

  # Simple Role Logic (Can be expanded to a full Pundit policy later)
  enum :role, { member: "member", admin: "admin" }, default: :member

  validates :user_id, uniqueness: { scope: :account_id }
end

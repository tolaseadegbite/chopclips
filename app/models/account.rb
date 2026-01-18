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
end

class Project < ApplicationRecord
  include PublicIdentifiable
  include AccountScoped # From Authentication Zero for multitenancy

  has_public_id prefix: "proj"

  belongs_to :user
  has_many :clips, dependent: :destroy

  # Map Integers to Strings efficiently
  enum :status, {
    queued: 0,
    processing: 1,
    completed: 2,
    failed: 3
  }, default: :queued

  validates :s3_key, presence: true

  # Helper for turbo updates
  after_update_commit -> { broadcast_replace_to "projects_#{account.public_id}", partial: "projects/project_row", locals: { project: self } }
end

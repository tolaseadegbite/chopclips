class Clip < ApplicationRecord
  include PublicIdentifiable
  include AccountScoped

  has_public_id prefix: "clip"

  belongs_to :project
  belongs_to :user

  enum :status, {
    created: 0,
    processing: 1,
    ready: 2,
    failed: 3
  }, default: :created

  def video_url
    return nil unless s3_key
    # Assuming you have the S3Signer service
    S3Signer.new.sign(s3_key)
  end
end

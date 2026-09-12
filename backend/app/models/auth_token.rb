# frozen_string_literal: true

class AuthToken < ApplicationRecord
  belongs_to :membership

  validates :token_digest, :expires_at, presence: true

  scope :active, -> { where(revoked_at: nil).where('expires_at > ?', Time.current) }

  def active?
    revoked_at.nil? && expires_at.future?
  end

  def revoke!
    update!(revoked_at: Time.current)
  end
end

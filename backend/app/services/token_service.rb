# frozen_string_literal: true

class TokenService
  REFRESH_TOKEN_TTL = 30.days

  def self.issue_for(membership)
    raw_refresh_token = SecureRandom.urlsafe_base64(48)
    refresh_token = AuthToken.create!(
      membership: membership,
      token_digest: digest(raw_refresh_token),
      expires_at: REFRESH_TOKEN_TTL.from_now
    )

    {
      access_token: JwtService.encode(membership),
      refresh_token: raw_refresh_token,
      expires_in: JwtService::ACCESS_TOKEN_TTL.to_i,
      token_type: 'Bearer',
      auth_token_id: refresh_token.id
    }
  end

  def self.rotate(raw_refresh_token)
    token = AuthToken.active.find_by(token_digest: digest(raw_refresh_token))
    raise JwtService::InvalidToken, 'Invalid or expired refresh token' unless token

    AuthToken.transaction do
      token.revoke!
      replacement = issue_for(token.membership)
      token.update!(replaced_by_id: replacement[:auth_token_id])
      replacement
    end
  end

  def self.revoke(raw_refresh_token)
    AuthToken.active.find_by(token_digest: digest(raw_refresh_token))&.revoke!
  end

  def self.digest(raw_token)
    Digest::SHA256.hexdigest(raw_token)
  end
  private_class_method :digest
end

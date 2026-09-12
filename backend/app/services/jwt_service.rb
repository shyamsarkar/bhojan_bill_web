# frozen_string_literal: true

class JwtService
  ALGORITHM = 'HS256'
  ACCESS_TOKEN_TTL = 15.minutes

  class InvalidToken < StandardError; end

  def self.encode(membership, expires_at: ACCESS_TOKEN_TTL.from_now)
    payload = {
      membership_id: membership.id,
      exp: expires_at.to_i,
      iat: Time.current.to_i
    }

    JWT.encode(payload, Rails.application.secret_key_base, ALGORITHM)
  end

  def self.decode(token)
    payload, = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: ALGORITHM)
    payload.symbolize_keys
  rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError, JWT::InvalidIssuerError => e
    raise InvalidToken, e.message
  end
end

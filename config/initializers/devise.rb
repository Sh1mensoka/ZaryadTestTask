# frozen_string_literal: true

Devise.setup do |config|
  require 'devise/orm/active_record'

  config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 12
  config.password_length = 6..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.reset_password_within = 6.hours
  config.sign_out_via = :post

  config.api.configure do |api|
    # Access Token
    api.access_token.expires_in = 1.hour
    api.access_token.expires_in_infinite = ->(_resource_owner) { false }
    api.access_token.generator = ->(_resource_owner) { Devise.friendly_token(60) }


    # Refresh Token
    api.refresh_token.enabled = true
    api.refresh_token.expires_in = 1.week
    api.refresh_token.generator = ->(_resource_owner) { Devise.friendly_token(60) }
    api.refresh_token.expires_in_infinite = ->(_resource_owner) { false }

    # Sign up
    api.sign_up.enabled = true

    # Authorization
    api.authorization.key = 'Authorization'
    api.authorization.scheme = 'Bearer'
    api.authorization.location = :header
  end
end

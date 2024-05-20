# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'
require './app/middleware/idempotent_request'

Bundler.require(*Rails.groups)

module CarRentalTest
  class Application < Rails::Application
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use IdempotentRequest
    config.session_store :cookie_store, key: 'session'
    config.middleware.use config.session_store, config.session_options

    config.load_defaults 7.0

    config.api_only = true
  end
end

# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :authenticate_devise_api_token!
end

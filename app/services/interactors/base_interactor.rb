# frozen_string_literal: true

class Interactors::BaseInteractor
  def self.call
    raise NotImplementedError
  end

  protected

  def self.build_success_message(resource)
    [
      resource,
      200
    ]
  end

  def self.build_error_message(message, status = :bad_request)
    [
      {
        message: message,
        status: status
      },
      status
    ]
  end
end
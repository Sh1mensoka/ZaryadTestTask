# frozen_string_literal: true

class Interactors::Rents::Start < Interactors::BaseInteractor
  def self.call(user_id:, car_id:)
    begin
      rent = ActiveRecord::Base.transaction do
        car = Car.find(car_id).tap { |car| car.start_rent! }

        Rent.create!(user_id: user_id, car: car)
      end

      Rails.logger.info { 'Rent was successfully started' }
      build_success_message(rent)
    rescue AASM::InvalidTransition => e
      Rails.logger.error { "Failed to start a new rent, reason: #{e}" }
      build_error_message("Car can't be rented", 422)
    end
  end
end

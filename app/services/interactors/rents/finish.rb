# frozen_string_literal: true

class Interactors::Rents::Finish < Interactors::BaseInteractor
  def self.call(rent_id:)
    begin
      finished_rent = ActiveRecord::Base.transaction do
        Rent.includes(:car).find_by(id: rent_id).tap { |rent|
          rent.finish!
          rent.car.finish_rent!
        }
      end

      Rails.logger.info { 'The rent was successfully finished' }
      build_success_message(finished_rent)
    rescue AASM::InvalidTransition => e
      Rails.logger.error { "Failed to finish the rent, reason: #{e}" }
      build_error_message("Rent can't be finished right now or already finished", 422)
    end
  end
end

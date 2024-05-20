# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Interactors::Rents::Start, type: :interactor do
  describe '#call' do
    subject(:interaction) { described_class.call(**params) }

    let(:params) { {user_id: user.id, car_id: car.id} }
    let(:user) { create :user }

    context 'when rent can be started' do
      let(:car) { create :car, status: 'available' }

      it 'starts rent and set car status as in_rent' do
        expect { interaction }
        .to change(Rent, :count).by(1)
        .and change { car.reload.status }.from('available').to('in_rent')
        
        expect(interaction).to contain_exactly(Rent.take, 200)
      end
    end

    context 'when car can not be rented' do
      let(:car) { create :car, status: 'unavailable' }

      it 'doesnt start rent, doesnt change car status and returns error message' do
        expect { interaction }
        .to not_change(Rent, :count)
        .and not_change { car.status }
        
        expect(interaction).to contain_exactly(
          {
            message: "Car can't be rented",
            status: 422
          },
          422
        )
      end
    end
  end
end

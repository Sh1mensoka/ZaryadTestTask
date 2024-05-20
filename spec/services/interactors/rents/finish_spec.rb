# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Interactors::Rents::Finish, type: :interactor do
  describe '#call' do
    subject(:interaction) { described_class.call(**params) }

    let(:params) { {rent_id: rent.id} }

    context 'when rent can be finished' do
      let(:car)  { create :car, status: 'in_rent' }
      let(:rent) { create :rent, car: car }

      it 'finishes rent and set car status as available' do
        expect { interaction }
        .to change { rent.reload.status }.from('started').to('finished')
        .and change { car.reload.status }.from('in_rent').to('available')
        
        expect(interaction).to contain_exactly(rent, 200)
      end
    end

    context 'when rent is already finished' do
      let(:rent) { create :rent, status: 'finished' }

      it 'doesnt change rent and car status and returns error message' do
        expect { interaction }
        .to not_change { rent.reload.status }
        .and not_change { rent.car.status }
        
        expect(interaction).to contain_exactly(
          {
            message: "Rent can't be finished right now or already finished",
            status: 422
          },
          422
        )
      end
    end
  end
end

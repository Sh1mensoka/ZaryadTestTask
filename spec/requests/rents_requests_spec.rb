# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Rent requests', type: :request do
  subject(:sign_in_request) { post '/users/tokens/sign_in', params: sign_in_params, headers: sign_in_headers }

  let(:sign_in_params) { {email: user.email, password: user.password} }
  let(:sign_in_headers) { {'ACCEPT' => 'application/json'} }

  let(:user) { create :user, email: 'example@example.com', password: 'example123' }

  before do
    allow(Interactors::Rents::Start).to receive(:call).and_call_original
    allow(Interactors::Rents::Finish).to receive(:call).and_call_original
    allow(REDIS).to receive(:hgetall).and_call_original
  end

  shared_context 'when not logged in / no authorization token passed' do
    it 'responds with a 401 error' do
      request

      expect(response.content_type).to start_with("application/json")
      expect(response).to have_http_status(:unauthorized)
      expect(Oj.load(response.body)).to eq(
        {
          "error" => "invalid_token",
          "error_description" => [
            "Invalid token"
          ]
        }
      )
    end
  end

  describe 'POST /rents/start_rental' do
    subject(:request) { post '/rents/start_rental', params: params, headers: headers }

    let(:params) { {rent: {car_id: car.id}} }
    let(:headers) do 
      {
        'ACCEPT' => 'application/json',
        'HTTP_IDEMPOTENCY_KEY' => idempotency_key
      }
    end
    let(:idempotency_key) { SecureRandom.uuid }

    let(:car) { create :car }

    context 'when logged in' do
      before do
        sign_in_request

        headers.merge!(
          {
            'AUTHORIZATION' => "Bearer #{Oj.load(response.body)["token"]}"
          }
        )
      end

      context 'with single request' do
        it 'starts new rental' do
          request

          expect(response.content_type).to start_with("application/json")
          expect(response).to have_http_status(:ok)
          expect(Oj.load(response.body)).to eq(
            {
              "car" => {
                "id" => car.id,
                "license_number" => car.license_number,
                "model" => car.model,
                "status" => car.reload.status
              },
              "id" => Rent.take.id,
              "status" => "started",
              "user" => {
                "email" => user.email,
                "id" => user.id
              }
            }
          )
        end
      end

      context 'with 2 requests' do
        it 'starts new rental and returns previous result on second request' do
          2.times do
            request
          end

          expect(response.content_type).to start_with("application/json")
          expect(response).to have_http_status(:ok)
          expect(Oj.load(response.body)).to eq(
            {
              "car" => {
                "id" => car.id,
                "license_number" => car.license_number,
                "model" => car.model,
                "status" => car.reload.status
              },
              "id" => Rent.take.id,
              "status" => "started",
              "user" => {
                "email" => user.email,
                "id" => user.id
              }
            }
          )

          expect(Interactors::Rents::Start).to have_received(:call).exactly(1).time
          expect(REDIS).to have_received(:hgetall).exactly(1).times
        end
      end

      context 'when have active rent' do
        let(:idempotency_key) { SecureRandom.uuid }

        before do
          create :rent, user: user
        end

        it 'responds with a 400 error' do
          request

          expect(response.content_type).to start_with("application/json")
          expect(response).to have_http_status(:bad_request)
          expect(Oj.load(response.body)).to eq(
            {
              "message" => "You can't rent a car while you have active rent",
              "status" => 400
            }
          )
        end
      end
    end

    include_context 'when not logged in / no authorization token passed'
  end

  describe 'POST /rents/end_rental' do
    subject(:request) { post '/rents/end_rental', params: params, headers: headers }

    let(:params) { {rent: {id: rent.id}} }
    let(:headers) do 
      {
        'ACCEPT' => 'application/json',
        'HTTP_IDEMPOTENCY_KEY' => idempotency_key
      }
    end
    let(:idempotency_key) { SecureRandom.uuid }

    let(:rent) { create :rent, user: user, car: car }
    let(:car)  { create :car, status: 'in_rent' }

    context 'when logged in' do
      before do
        sign_in_request

        headers.merge!(
          {
            'AUTHORIZATION' => "Bearer #{Oj.load(response.body)["token"]}"
          }
        )
      end

      context 'with single request' do
        it 'finishes rental' do
          request

          expect(response.content_type).to start_with("application/json")
          expect(response).to have_http_status(:ok)
          expect(Oj.load(response.body)).to eq(
            {
              "id" => rent.id,
              "status" => rent.reload.status,
              "user" => {
                "id" => user.id,
                "email" => user.email
              },
              "car" => {
                "id" => car.id ,
                "model" => car.model,
                "license_number" => car.license_number,
                "status" => car.reload.status
              }
            }
          )
        end
      end

      context 'with 2 requests' do
        it 'finishes rental and returns previous result on second request' do
          2.times do
            request
          end

          expect(response.content_type).to start_with("application/json")
          expect(response).to have_http_status(:ok)
          expect(Oj.load(response.body)).to eq(
            {
              "id" => rent.id,
              "status" => rent.reload.status,
              "user" => {
                "id" => user.id,
                "email" => user.email
              },
              "car" => {
                "id" => car.id ,
                "model" => car.model,
                "license_number" => car.license_number,
                "status" => car.reload.status
              }
            }
          )

          expect(Interactors::Rents::Finish).to have_received(:call).exactly(1).time
          expect(REDIS).to have_received(:hgetall).exactly(1).times
        end
      end

      context 'when rent has already been finished' do
        let(:idempotency_key) { SecureRandom.uuid }

        let(:rent) { create :rent, user: user, status: 'finished' }

        it 'responds with a 400 error' do
          request

          expect(response.content_type).to start_with("application/json")
          expect(response).to have_http_status(:bad_request)
          expect(Oj.load(response.body)).to eq(
            {
              "message" => "Rent has already been finished or doesn't exist",
              "status" => 400
            }
          )
        end
      end
    end

    include_context 'when not logged in / no authorization token passed'
  end
end

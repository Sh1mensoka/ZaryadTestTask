# frozen_string_literal: true

FactoryBot.define do
  factory :car do
    model { Faker::Device.manufacturer }
    license_number { Faker::DrivingLicence.northern_irish_driving_licence }
  end
end
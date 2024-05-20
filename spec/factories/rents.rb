# frozen_string_literal: true

FactoryBot.define do
  factory :rent do
    user { create :user }
    car { create :car, status: 'in_rent' }
  end
end
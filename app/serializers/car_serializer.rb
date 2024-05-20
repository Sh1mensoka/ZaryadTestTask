# frozen_string_literal: true

class CarSerializer < ActiveModel::Serializer
  attributes :id, :model, :license_number, :status
end

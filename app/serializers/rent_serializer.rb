# frozen_string_literal: true

class RentSerializer < ActiveModel::Serializer
  attributes :id, :status
  belongs_to :user
  belongs_to :car
end
